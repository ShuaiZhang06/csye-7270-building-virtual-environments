# FRICTIONAL — Assignment 3, walker-rudy

What I tried, what I expected, what happened, how I checked it, what I did about it, and what I learned, with my work and Claude's kept apart.

**How this file is written.** Claude Code drafts each entry from our Claude Code conversations and their timestamps, and I check it against what I actually did. Where I recorded no expectation or lesson, the entry says so instead of inventing one. Each entry says when it was written; entries written after the event are labelled as retrospective.

**Tools.** Claude Opus 5.5 in Claude Code (desktop app), Claude Code 2.1.296; Blender 5.2.2 LTS; Godot 4.7.2; MCP for Blender (`mcp-for-blender` 2.1.9, add-on 1.8); macOS.

---

## 2026-10-12 — Learning Blender's window

*Retrospective, written on 2026-10-13.*

- **Attempt (me):** before any prompting, I opened Blender 5.2.2 and looked at the window with the default scene.
- **Result:** [BLENDER-NOTES.md](BLENDER-NOTES.md), the six parts in my own words, and a screenshot of my session with the Cube selected and the sidebar on the Item tab.
- **Human / AI:** the text and the screenshot are mine. Claude converted the screenshot from WebP to PNG and added it to the file; it did not change my text.

## 2026-10-12 — The connector I already had was a different MCP

*Retrospective, written on 2026-10-13.*

- **Expected:** that I had already connected Claude to Blender through a connector in the Claude app.
- **Check (Claude):** read the connector's manifest, `~/Library/Application Support/Claude/Claude Extensions/ant.dir.gh.blender.blender-mcp/manifest.json`.
- **What happened:** it is Blender Lab's MCP server (1.0.1, `projects.blender.org/lab/blender_mcp`), not the community project the assignment names (`ahujasid/mcp-for-blender`). Its tools differ: no `get_scene_info` and no `look`. No Blender extension for it was found in my Blender 5.2 user folder, so there is no evidence it ever reached my Blender.
- **Response (me):** I installed the assignment's MCP instead, and turned the Blender Lab connector off by hand in the Claude app so that only one Blender server is offered to Claude.
- **Human / AI:** Claude found and read the manifest; I chose to switch and turned the connector off.

## 2026-10-12 — Installing MCP for Blender

*Retrospective, written on 2026-10-13. Every command and its full output: [evidence/mcp-setup-log.md](evidence/mcp-setup-log.md).*

- **Attempt:** the assignment's manual steps. Claude ran all the terminal commands in my Claude Code session, from 22:55 EDT.
- **Checks before installing (Claude):** `mcp-for-blender` on PyPI (2.1.9) points to ahujasid's repository, and the README's manual steps, fetched that evening, match the assignment's.
- **Install uv — skipped.** uv 0.10.2 was already installed with uv's official standalone installer (`~/.local/bin`), not Homebrew (`brew list uv`: `No such keg`). The README accepts that installer, so Claude did not install a second copy. Differs from the assignment.
- **Register the server — failed once.**
  - The assignment's line `claude mcp add -e DISABLE_TELEMETRY=true blender -- uvx mcp-for-blender` returned `Invalid environment variable format: blender, environment variables should be added as: -e KEY1=value1 -e KEY2=value2` and exit code 1.
  - Diagnosis (Claude): `claude mcp add --help` shows `-e, --env <env...>`, which takes several values, so it swallowed the server name. The help's own example puts the name first.
  - Response: `claude mcp add blender -e DISABLE_TELEMETRY=true -- uvx mcp-for-blender`, which succeeded. The server is in **local** scope: only Claude Code sessions started in `~/csye7270/course-fork` see it.
  - `claude mcp get blender` then said `✔ Connected` although Blender was closed: that only means Claude Code could start the server process.
- **Install the add-on — worked first time.** `uvx mcp-for-blender install-addon` copied `blender_mcp.py` (add-on 1.8, SHA-256 `eb0facf6…297fa5`) into `~/Library/Application Support/Blender/5.2/scripts/addons/` at 22:56 EDT.
- **Defaults, read from the add-on's code (Claude):** the socket listens on `localhost:9876` and starts automatically whenever Blender opens with the add-on enabled; Poly Haven, Sketchfab, Poly Pizza, Hyper3D, Hunyuan3D and Tripo are off; content telemetry is off.
- **In Blender (me):** I enabled **Interface: MCP for Blender** in Preferences. The sidebar's MCP for Blender tab showed "Connected on port 9876" and "Addon 1.8 · up to date", with every library and generator checkbox off ([evidence/mcp-panel-connected.png](evidence/mcp-panel-connected.png)).
- **Check that it worked:** in a new Claude Code session at 23:08 EDT, I asked whether Claude could see the Blender MCP; its `get_addon_status` call returned Blender 5.2.2 LTS, protocol 13 of 13 expected, every library and generator off. Claude repeated the call on 2026-10-13 with the same result.
- **Time:** about 15 minutes, from the first command at 22:55 to the working check at 23:08 EDT, well inside the two-hour time box.
- **Unresolved:** I cannot verify that `DISABLE_TELEMETRY=true` stops the anonymous usage record; I have no network check of what the server sends.
- **Human / AI:** Claude ran every terminal command, diagnosed the `-e` order from the help text, and read the add-on's code. I did the steps in Blender's window and checked the panel.

## 2026-10-13 — The server needs Blender open

*Written on 2026-10-13, from the conversation.*

- **Attempt (me):** asked Claude, in that Claude Code session, to call `get_scene_info`.
- **What happened:** at 18:09 EDT it returned `Error getting scene info: Could not connect to Blender. Make sure the Blender addon is running.`
- **Question I asked:** whether Blender must be open, with the MCP server connected, whenever I want to use it.
- **Response (me):** I opened Blender, and at 18:10 EDT the same call returned my scene: `1 camera, 1 light, 1 mesh`, the Cube at `(0.0, 0.0, 0.0)`, `size 2.0x2.0x2.0`, `unit scale 1.0`.
- **What this shows:** the Claude Code side starts on its own, but every tool call needs Blender running with the add-on's server listening.
- **To do:** disable the add-on in Preferences when I am not working on this assignment, because its socket opens every time Blender starts.
