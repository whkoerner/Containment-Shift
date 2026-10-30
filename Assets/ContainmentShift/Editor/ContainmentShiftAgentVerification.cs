#if UNITY_EDITOR
using System;
using System.IO;
using System.Linq;
using Unity.Netcode;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.LowLevel;

/// <summary>
/// Real Editor entry points. Never regenerates a scene or changes input settings.
/// Synthetic movement evidence is deliberately distinct from human playtesting.
/// </summary>
[InitializeOnLoad]
public static class ContainmentShiftAgentVerification
{
    private const string Pending = "ContainmentShiftAgentSmokePending";
    private static Keyboard keyboard;
    private static Mouse mouse;
    private static int stage;
    private static double stageStart;
    private static Vector3 baseline;
    private static float walkDistance;
    private static Quaternion viewRotation;
    private static float peakY;
    private static bool completed;
    private static string failure;

    [Serializable]
    private sealed class Evidence
    {
        public string run_id;
        public string time_utc;
        public string editor;
        public string scene;
        public string level;
        public bool passed;
        public string details;
    }

    static ContainmentShiftAgentVerification()
    {
        EditorApplication.playModeStateChanged += PlayState;
        EditorApplication.update += Tick;
        Application.logMessageReceived += CaptureException;
    }

    private static string Arg(string key, string fallback = "")
    {
        string[] args = Environment.GetCommandLineArgs();
        int index = Array.IndexOf(args, key);
        return index >= 0 && index + 1 < args.Length ? args[index + 1] : fallback;
    }

    private static string Scene => Arg("-csScene", "Assets/ContainmentShift/Scenes/Annex_Greybox.unity");

    private static void Write(bool passed, string level, string details)
    {
        string destination = Arg("-csEvidence");
        if (string.IsNullOrEmpty(destination)) throw new Exception("Missing -csEvidence destination");
        Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(destination)));
        var evidence = new Evidence { run_id = Arg("-csRunId"), time_utc = DateTime.UtcNow.ToString("o"),
            editor = Application.unityVersion, scene = Scene, level = level, passed = passed, details = details };
        File.WriteAllText(destination, JsonUtility.ToJson(evidence, true));
        Debug.Log("CONTAINMENT_SHIFT_AGENT_EVIDENCE " + level + " passed=" + passed);
    }

    private static void ValidateSource()
    {
        if (!File.Exists(Scene)) throw new Exception("Required existing scene is missing: " + Scene);
        if (EditorUtility.scriptCompilationFailed) throw new Exception("Script compilation failed");
#if !ENABLE_INPUT_SYSTEM
        throw new Exception("New Input System backend is disabled. Set Active Input Handling to Both and restart the Editor.");
#endif
        string[] prefabGuids = AssetDatabase.FindAssets("NetworkPlayer t:Prefab");
        if (prefabGuids.Length != 1) throw new Exception("Expected one NetworkPlayer prefab");
        GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(AssetDatabase.GUIDToAssetPath(prefabGuids[0]));
        if (prefab.GetComponent<CoopPlayerMotor>() == null || prefab.GetComponent<CharacterController>() == null ||
            prefab.GetComponent<NetworkObject>() == null) throw new Exception("Player prefab lacks required components");
        var settings = new SerializedObject(prefab.GetComponent<CoopPlayerMotor>());
        foreach (string property in new[] { "movementSettings", "cameraPivot", "playerCamera", "playerAudioListener" })
            if (settings.FindProperty(property)?.objectReferenceValue == null) throw new Exception("Missing player reference: " + property);
    }

    public static void Compile()
    {
        ValidateSource();
        Write(true, "EDITOR_COMPILE_AND_PREFAB_CHECK", "Editor loaded compiled scripts, input define is enabled, existing scene and player references exist. Gameplay not established.");
    }

    public static void Build()
    {
        ValidateSource();
        string destination = Path.GetFullPath("Builds/Workforce/ContainmentShift.exe");
        Directory.CreateDirectory(Path.GetDirectoryName(destination));
        BuildReport report = BuildPipeline.BuildPlayer(new BuildPlayerOptions {
            scenes = new[] { Scene }, locationPathName = destination,
            target = BuildTarget.StandaloneWindows64, options = BuildOptions.Development });
        bool passed = report != null && report.summary.result == BuildResult.Succeeded && File.Exists(destination);
        Write(passed, "STANDALONE_BUILD_ONLY", destination + "; runtime not verified");
        if (!passed) throw new Exception("Windows development build failed");
    }

    public static void MovementSmoke()
    {
        ValidateSource();
        EditorSceneManager.OpenScene(Scene, OpenSceneMode.Single);
        SessionState.SetBool(Pending, true);
        SessionState.SetString(Pending + "Started", DateTime.UtcNow.ToString("o"));
        SessionState.SetBool(Pending + "Passed", false);
        EditorApplication.isPlaying = true;
    }

    private static void CaptureException(string condition, string stack, LogType type)
    {
        if (SessionState.GetBool(Pending, false) && (type == LogType.Exception || type == LogType.Error))
            failure = condition + "\n" + stack;
    }

    private static void PlayState(PlayModeStateChange state)
    {
        if (!SessionState.GetBool(Pending, false)) return;
        if (state == PlayModeStateChange.EnteredPlayMode)
        {
            stage = 0;
            stageStart = EditorApplication.timeSinceStartup;
        }
        if (state == PlayModeStateChange.EnteredEditMode)
        {
            bool passed = SessionState.GetBool(Pending + "Passed", false);
            SessionState.SetBool(Pending, false);
            EditorApplication.delayCall += () => EditorApplication.Exit(passed ? 0 : 1);
        }
    }

    private static void Hold(params Key[] keys)
    {
        InputSystem.QueueStateEvent(keyboard, new KeyboardState(keys));
    }

    private static void Next()
    {
        stage++;
        stageStart = EditorApplication.timeSinceStartup;
    }

    private static void Finish(bool passed, string details)
    {
        if (completed) return;
        completed = true;
        if (keyboard != null) InputSystem.RemoveDevice(keyboard);
        if (mouse != null) InputSystem.RemoveDevice(mouse);
        if (NetworkManager.Singleton != null && NetworkManager.Singleton.IsListening) NetworkManager.Singleton.Shutdown();
        SessionState.SetBool(Pending + "Passed", passed);
        Write(passed, "SYNTHETIC_EDITOR_MOVEMENT_SMOKE", details +
            " Human keyboard/mouse, Escape UI, wall collisions, standalone and independent multiplayer remain MANUAL_VERIFICATION_REQUIRED.");
        EditorApplication.isPlaying = false;
    }

    private static void Tick()
    {
        if (!SessionState.GetBool(Pending, false) || completed) return;
        if (DateTime.TryParse(SessionState.GetString(Pending + "Started", ""), out DateTime started) &&
            DateTime.UtcNow - started.ToUniversalTime() > TimeSpan.FromSeconds(90))
        {
            if (EditorApplication.isPlaying) Finish(false, "Timed out entering or running Play Mode");
            else { Write(false, "SYNTHETIC_EDITOR_MOVEMENT_SMOKE", "Play Mode never started"); SessionState.SetBool(Pending, false); EditorApplication.Exit(1); }
            return;
        }
        if (!EditorApplication.isPlaying || EditorApplication.isCompiling || EditorApplication.isPaused) return;
        try
        {
            if (!string.IsNullOrEmpty(failure)) throw new Exception(failure);
            var network = UnityEngine.Object.FindFirstObjectByType<NetworkManager>();
            if (network == null) throw new Exception("Existing scene has no NetworkManager");
            double elapsed = EditorApplication.timeSinceStartup - stageStart;
            if (stage == 0)
            {
                InputSystem.settings.backgroundBehavior = InputSettings.BackgroundBehavior.IgnoreFocus;
                keyboard = InputSystem.AddDevice<Keyboard>("CSAgentSyntheticKeyboard");
                mouse = InputSystem.AddDevice<Mouse>("CSAgentSyntheticMouse");
                if (!network.StartHost()) throw new Exception("StartHost returned false");
                Next(); return;
            }
            if (network.LocalClient == null || network.LocalClient.PlayerObject == null) return;
            var player = network.LocalClient.PlayerObject;
            var motor = player.GetComponent<CoopPlayerMotor>();
            var controller = player.GetComponent<CharacterController>();
            var camera = player.GetComponentInChildren<Camera>(true);
            if (!motor.IsOwner || !controller.enabled || camera == null || !camera.enabled)
                throw new Exception("Spawned owner/controller/camera is not active");
            switch (stage)
            {
                case 1:
                    Hold();
                    if (elapsed < 1 || !controller.isGrounded) return;
                    baseline = player.transform.position; Next(); break;
                case 2:
                    Hold(Key.W);
                    if (elapsed < .5) return;
                    walkDistance = Vector3.Distance(baseline, player.transform.position);
                    if (walkDistance < .2f) throw new Exception("Synthetic W produced no meaningful movement");
                    baseline = player.transform.position; Next(); break;
                case 3:
                    Hold(Key.W, Key.LeftShift);
                    if (elapsed < .5) return;
                    float sprint = Vector3.Distance(baseline, player.transform.position);
                    if (sprint < walkDistance * 1.1f) throw new Exception("Sprint did not exceed walking displacement");
                    Hold(); baseline = player.transform.position; peakY = baseline.y; Next(); break;
                case 4:
                    Hold(Key.Space);
                    peakY = Mathf.Max(peakY, player.transform.position.y);
                    if (elapsed < .45) return;
                    if (peakY < baseline.y + .15f) throw new Exception("Synthetic Space did not produce a jump");
                    Hold(); viewRotation = camera.transform.rotation; Next(); break;
                case 5:
                    Hold();
                    InputSystem.QueueStateEvent(mouse, new MouseState { delta = new Vector2(12f, 3f) });
                    if (elapsed < .35) return;
                    if (Quaternion.Angle(viewRotation, camera.transform.rotation) < .2f)
                        throw new Exception("Synthetic mouse delta did not change camera look");
                    Finish(true, "Host owner spawned; controller/camera active; synthetic W, sprint, jump and mouse look produced measured changes in the existing scene."); break;
            }
        }
        catch (Exception e) { Finish(false, e.ToString()); }
    }
}
#endif
