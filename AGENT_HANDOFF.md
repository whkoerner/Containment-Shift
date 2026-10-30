# Development progress

Updated: 2026-10-30T23:56:35Z

Branch: `agent/workforce-20261030-165348-6e64ce`

Latest source/checkpoint commit: `2bcf9ff10687e61eac7c65d97adf15e3feda19c1`

Status: Running

## Evidence

- foundation-input: **pending** — Saved backend enables Input System; Unity compile and synthetic Play Mode movement smoke pass; human confirms WASD, look, sprint, jump, collision, Escape and disconnect/reconnect.
- network-ownership: **pending** — Owner alone reads input and enables camera; host/client independently move and disconnect cleanly. Independent two-client human verification required.
- interaction-research: **pending** — Pinned revisions, license bodies, dependency caveats, and integration recommendation saved. No gameplay progress claimed.

## Blocker

 are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
There are 2 audio listeners in the scene. Please ensure there is always exactly one audio listener in the scene.
CONTAINMENT_SHIFT_AGENT_EVIDENCE SYNTHETIC_EDITOR_MOVEMENT_SMOKE passed=False
UnityEngine.Debug:ExtractStackTraceNoAlloc (byte*,int,string)
UnityEngine.StackTraceUtility:ExtractStackTrace ()
UnityEngine.DebugLogHandler:Internal_Log (UnityEngine.LogType,UnityEngine.LogOption,string,UnityEngine.Object)
UnityEngine.DebugLogHandler:LogFormat (UnityEngine.LogType,UnityEngine.Object,string,object[])
UnityEngine.Logger:Log (UnityEngine.LogType,object)
UnityEngine.Debug:Log (object)
ContainmentShiftAgentVerification:Write (bool,string,string) (at Assets/ContainmentShift/Editor/ContainmentShiftAgentVerification.cs:68)
ContainmentShiftAgentVerification:Finish (bool,string) (at Assets/ContainmentShift/Editor/ContainmentShiftAgentVerification.cs:158)
ContainmentShiftAgentVerification:Tick () (at Assets/ContainmentShift/Editor/ContainmentShiftAgentVerification.cs:169)
UnityEditor.EditorApplication:Internal_CallUpdateFunctions ()

(Filename: Assets/ContainmentShift/Editor/ContainmentShiftAgentVerification.cs Line: 68)

Unloading 1 Unused Serialized files (Serialized files now loaded: 0)
Loaded scene 'Temp/__Backupscenes/0.backup'
	Deserialize:            1.278 ms
	Integration:            10.510 ms
	Integration of assets:  0.002 ms
	Thread Wait Time:       0.020 ms
	Total Operation Time:   11.811 ms
Unloading 1215 unused Assets / (390.1 KB). Loaded Objects now: 2556.
Memory consumption went from 283.4 MB to 283.1 MB.
Total: 9.611600 ms (FindLiveObjects: 0.611400 ms CreateObjectMapping: 0.075000 ms MarkObjects: 8.297100 ms  DeleteObjects: 0.342600 ms)

[Licensing::Client] Successfully resolved entitlement details
[Licensing::Module] License group:
  Id: F4-KMRA-NS8P-AG27-TQHK-XXXX
  Product: Unity Personal
  Type: ULF
  Expiration: Unlimited
[Licensing::Module] License group:
  Id: 1375300906649-UnityPersXXXX
  Product: Unity Personal
  Type: Assigned
  Expiration: Unlimited
[UnityConnectServicesConfig] config is NOT valid, switching to default
MonoPathRemapper: Attempts to remap: 6008; Successful remaps: 0
Serialized file version minimum: 23, current 23
[Physics::Module] Cleanup current backend.
[Physics::Module] Id: 0xf2b8ea05
Input System module state changed to: ShutdownInProgress.
Input Polling Thread exited.
Input System module state changed to: Shutdown.
[Licensing::IpcConnector] LicenseClient-whkoe-notifications channel disconnected successfully.
[Licensing::IpcConnector] LicenseClient-whkoe channel disconnected successfully.
Shut down.
Lingering sessions upon destruction of worker manager
Unity Data Store service was successfully shut down
UDS shutting down local client system
Shut down UDS service system complete
AcceleratorClientConnectionCallback - disconnected - :0
Cleanup mono
CodeReloadManager destroyed
abort_threads: Failed aborting id: 0000000000006EB8, mono_thread_manage will ignore it

abort_threads: Failed aborting id: 000000000000A600, mono_thread_manage will ignore it

abort_threads: Failed aborting id: 0000000000006EB8, mono_thread_manage will ignore it

abort_threads: Failed aborting id: 000000000000A600, mono_thread_manage will ignore it

debugger-agent: Unable to listen on 4944
VBCSCompilerPreWarmer: requested VBCSCompiler shutdown
Checking for leaked weakptr:
  Found no leaked weakptrs.
[Package Manager] Server process was shutdown
##utp:{"type":"MemoryLeaks","version":2,"phase":"Immediate","time":1793404595514,"processId":43044,"allocatedMemory":13677577,"memoryLabels":[{"Default":182256},{"Permanent":15516},{"NewDelete":69617},{"Thread":4205640},{"Manager":2349085},{"VertexData":8},{"Geometry":824},{"Texture":24},{"Shader":839065},{"Material":132},{"GfxDevice":58008},{"Animation":952},{"FreeType":8},{"FontEngine":736},{"Physics":1970},{"Physics2D":16},{"Serialization":34304},{"Input":42840},{"JobScheduler":256},{"TextLib":280},{"Mono":310},{"ScriptingNativeRuntime":1255176},{"BaseObject":49072},{"Resource":1444},{"Renderer":2504},{"Transform":4781},{"File":7393},{"WebCam":616},{"Culling":32},{"Terrain":11442},{"Wind":24},{"STL":40},{"String":485082},{"StaticString":3808},{"Utility":2675894},{"Curl":4238},{"PoolAlloc":2840},{"AI":80},{"TypeTree":17165},{"ScriptManager":18984},{"CodeReload":448},{"RuntimeInitializeOnLoadManager":64},{"Sprites":102},{"SpriteAtlas":120},{"GI":7816},{"Director":8296},{"CloudService":7440},{"WebRequest":4793},{"VR":49650},{"SceneManager":608},{"Video":208},{"LazyScriptCache":32},{"Camera":729},{"Secure":2377},{"SerializationCache":9256},{"APIUpdating":10320},{"Subsystems":336},{"VirtualTexturing":57888},{"StaticSafetyDebugInfo":278528},{"Analytics":768},{"Hierarchy":1188},{"UIElements":40},{"CoreStats":14456},{"Identifiers":7152},{"EntityIdStore":33088},{"Gui":128},{"EditorUtility":99550},{"VersionControl":8},{"Undo":931},{"AssetDatabase":669535},{"AssetImporter":40},{"EditorGi":328},{"UnityConnect":40465},{"Upm":1912},{"UpmDiagnostics":8},{"AssetCompliance":96},{"DrivenProperties":72},{"LocalIPC":260},{"ProfilerEditor":9746},{"CoreBusinessMetrics":3600},{"Windowing":456},{"Licensing":12757},{"AssetReference":32},{"IPCStream":32}]}


## Not verified

Standalone and independent multiplayer gameplay; human acceptance unless explicitly recorded.

[Real-time tests](docs/REAL_TIME_TESTS.md)

Resume: click START CONTAINMENT SHIFT AGENT. State and exact errors are in ignored `.workforce/`. No active runtime self-modification is allowed.
