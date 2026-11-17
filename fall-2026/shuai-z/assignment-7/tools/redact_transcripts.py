#!/usr/bin/env python3
"""Make the committed copies of the claude -p transcripts in sessions/.

The assignment text asks for "any claude -p transcript under about 1 MB
(otherwise a labelled excerpt)". The raw streams, sessions/*.jsonl, stay
local (.gitignore): they hold local paths, session IDs and the machine's
Claude Code set-up. This script writes, into sessions/transcripts/:

- session-<N>.jsonl for a stream under 1 MB: every event, redacted;
- session-<N>.excerpt.jsonl for a stream of 1 MB or more: a labelled
  excerpt, redacted, whose first line says what was left out.

Redaction, in both:
- the home folder, the repository and this assignment folder are written
  as <home>, <repo> and assignment-7; temporary folders as <tmp>; the
  project slug Claude Code builds from the repository path as <project>;
- each session ID becomes S<N>, after the session's prompt number;
- the init event keeps only cwd, model, permissionMode, apiKeySource,
  claude_code_version and the built-in tools; the machine's plugins, MCP
  servers, skills, slash commands, agents, memory and socket paths and
  start-up timing are dropped;
- rate_limit_event lines (account usage) are dropped.

An excerpt also drops the thinking_tokens progress events, thinking
blocks, and the tool_use_result and wire_tool_inputs fields (copies of
what the message already holds), cuts each tool result to its first 600
characters and each tool input string to its first 3000, and replaces
images with a note. Every
assistant text, every tool call, every permission denial and the result
event are kept. The prompt itself is not in a stream; it is
sessions/prompt-<N>.txt.

No path or name is written into this file: they are read at run time.
Run from the assignment folder:  python3 -I tools/redact_transcripts.py
"""

import json
import re
import subprocess
import sys
from pathlib import Path

LIMIT = 1024 * 1024
RESULT_CHARS = 600
INPUT_CHARS = 3000
INIT_KEEP = ("type", "subtype", "cwd", "session_id", "model", "permissionMode",
             "apiKeySource", "claude_code_version", "tools", "uuid")

here = Path(__file__).resolve().parent.parent  # the assignment folder
repo = Path(subprocess.check_output(["git", "-C", str(here), "rev-parse", "--show-toplevel"], text=True).strip())
home = Path.home()
sessions = here / "sessions"
out_dir = sessions / "transcripts"

# Longest first, so the assignment folder is not written as <repo>/...
REPLACE = [
    (str(here), "assignment-7"),
    (str(repo), "<repo>"),
    (str(home), "<home>"),
    (str(home).replace("/", "-"), "-<home>"),
]
TMP = re.compile(r"/private/tmp/claude-\d+|/private/tmp|/tmp/cc-socks")


def session_ids() -> dict:
    """Each session ID, from the streams' result events, to S<N>."""
    ids = {}
    for f in sorted(sessions.glob("session-*.jsonl")):
        n = f.stem.removeprefix("session-")
        base = re.sub(r"[a-z]$", "", n)  # 17b resumes 17: same ID, same name
        for line in f.open():
            o = json.loads(line)
            if o.get("type") == "result":
                ids.setdefault(o["session_id"], "S" + base)
    return ids


def redact(text: str, ids: dict) -> str:
    for old, new in REPLACE:
        text = text.replace(old, new)
    text = TMP.sub("<tmp>", text)
    for old, new in ids.items():
        text = text.replace(old, new)
    return text


def cut(s: str, n: int) -> str:
    return s if len(s) <= n else s[:n] + f" [... {len(s) - n} more characters left out of this excerpt]"


def excerpt_content(content):
    """A message's content, cut for an excerpt."""
    if not isinstance(content, list):
        return content
    out = []
    for c in content:
        t = c.get("type")
        if t == "thinking":
            continue
        if t == "tool_use":
            c = dict(c)
            c["input"] = {k: cut(v, INPUT_CHARS) if isinstance(v, str) else v for k, v in c["input"].items()}
        elif t == "tool_result":
            c = dict(c)
            r = c.get("content")
            if isinstance(r, str):
                c["content"] = cut(r, RESULT_CHARS)
            elif isinstance(r, list):
                parts = []
                for p in r:
                    if p.get("type") == "image":
                        parts.append({"type": "text", "text": "[an image, left out of this excerpt]"})
                    elif p.get("type") == "text":
                        parts.append({"type": "text", "text": cut(p.get("text", ""), RESULT_CHARS)})
                    else:
                        parts.append(p)
                c["content"] = parts
        out.append(c)
    return out


def events(f: Path, excerpt: bool):
    for line in f.open():
        o = json.loads(line)
        t, st = o.get("type"), o.get("subtype")
        if t == "rate_limit_event":
            continue
        if t == "system" and st == "init":
            o = {k: o[k] for k in INIT_KEEP if k in o}
            o["tools"] = [x for x in o.get("tools", []) if not x.startswith("mcp__")]
        if excerpt:
            if t == "system" and st == "thinking_tokens":
                continue
            if t in ("assistant", "user") and "message" in o:
                o = {k: v for k, v in o.items() if k not in ("tool_use_result", "wire_tool_inputs")}
                o["message"] = dict(o["message"])
                o["message"]["content"] = excerpt_content(o["message"].get("content"))
        yield o


def main() -> int:
    ids = session_ids()
    out_dir.mkdir(exist_ok=True)
    for f in sorted(sessions.glob("session-*.jsonl"), key=lambda p: [int(x) if x.isdigit() else x for x in re.split(r"(\d+)", p.name)]):
        size = f.stat().st_size
        excerpt = size >= LIMIT
        name = f.stem + (".excerpt.jsonl" if excerpt else ".jsonl")
        lines = []
        if excerpt:
            note = {"type": "excerpt_note",
                    "source": f"sessions/{f.name}, {size} bytes, kept local",
                    "kept": "every assistant text and tool call, every tool result's first "
                            f"{RESULT_CHARS} characters, every permission denial, the result event; the prompt is "
                            "not in the stream, and is sessions/prompt-<N>.txt",
                    "left_out": f"thinking blocks and thinking_tokens events; the tool_use_result and wire_tool_inputs copies; tool results past {RESULT_CHARS} "
                                f"characters; tool input strings past {INPUT_CHARS} characters; images; "
                                "rate-limit events; the init event's machine set-up",
                    "redacted": "local paths as <home>, <repo>, assignment-7, <tmp>; session IDs as S<N>",
                    "made_by": "tools/redact_transcripts.py"}
            lines.append(json.dumps(note, ensure_ascii=False))
        for o in events(f, excerpt):
            lines.append(json.dumps(o, ensure_ascii=False))
        text = redact("\n".join(lines) + "\n", ids)
        for leak in (str(home), str(home).replace("/", "-"), "/private/tmp/"):
            assert leak not in text, (f.name, leak)
        for line in text.splitlines():
            json.loads(line)
        (out_dir / name).write_text(text)
        print(f"{f.name:22s} {size / LIMIT:5.2f} MB -> {name:30s} {len(text.encode()) / LIMIT:5.2f} MB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
