# Bugs

No runtime defects have been confirmed, because Unity has not been run.

**Potential risks to verify**, not reported as observed bugs:
- First import may reveal compile errors or missing package/core assemblies.
- Camera/body mesh may clip in some views; this is a graybox visual only.
- A locally velocity-driven grabbed rigidbody may oscillate or clip at high speed, particularly in prop stacks.
- URP package has been declared but its renderer pipeline asset is not configured.
- Scene generator creates a two-room local prototype; it is not a multiplayer demo.

When reproducing a real failure, add Unity version, steps, expected/actual, logs, severity and commit.

