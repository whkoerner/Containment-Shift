#if UNITY_EDITOR
using System.IO;
using Unity.Netcode;
using Unity.Netcode.Transports.UTP;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// One-click first-phase test environment. Creates a scene, a network player
/// prefab, a NetworkManager, floor/walls, a lamp, and a waiting-screen camera.
/// </summary>
public static class CoopPrototypeSceneBuilder
{
    private const string Root = "Assets/ContainmentShift";
    private const string PrefabPath = Root + "/Prefabs/NetworkPlayer.prefab";
    private const string ScenePath = Root + "/Scenes/Annex_Greybox.unity";
    private const string SettingsPath = Root + "/Data/PlayerMovementSettings.asset";

    [MenuItem("Tools/Containment Shift/Create First Graybox Scene")]
    public static void EnsureTestScene()
    {
        if (EditorApplication.isPlaying)
        {
            Debug.LogWarning("Exit Play mode before building the test scene.");
            return;
        }
        // Preserve edited scenes; safe for unattended batch mode.
        if (File.Exists(ScenePath))
        {
            Debug.Log("Graybox scene already exists; preserving modifications.");
            return;
        }
        if (!Application.isBatchMode && !EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) return;

        Directory.CreateDirectory(Root + "/Prefabs");
        Directory.CreateDirectory(Root + "/Scenes");
        Directory.CreateDirectory(Root + "/Data");
        AssetDatabase.Refresh();

        Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        CreateBlock("Floor", new Vector3(0f, -0.5f, 0f), new Vector3(30f, 1f, 30f));
        CreateBlock("North Wall", new Vector3(0f, 2f, 15f), new Vector3(30f, 4f, 1f));
        CreateBlock("South Wall", new Vector3(0f, 2f, -15f), new Vector3(30f, 4f, 1f));
        CreateBlock("East Wall", new Vector3(15f, 2f, 0f), new Vector3(1f, 4f, 30f));
        CreateBlock("West Wall", new Vector3(-15f, 2f, 0f), new Vector3(1f, 4f, 30f));
        CreateBlock("Coolant Pump - PLACEHOLDER", new Vector3(-4f, 1.0f, 5f), new Vector3(2f, 2f, 2f));
        CreateBlock("Heat Exchanger - PLACEHOLDER", new Vector3(6f, 1.6f, -4f), new Vector3(3f, 3.2f, 2f));
        CreateBlock("Electrical Panel - PLACEHOLDER", new Vector3(12f, 1.4f, 0f), new Vector3(0.6f, 2.8f, 2.2f));
        CreateBlock("Extraction Door - PLACEHOLDER", new Vector3(0f, 1.6f, 13.5f), new Vector3(4f, 3.2f, 0.5f));
        CreateBlock("Coolant Tank - PLACEHOLDER", new Vector3(-10f, 2.0f, -7f), new Vector3(3f, 4f, 3f));
        CreateBlock("Emergency Console - PLACEHOLDER", new Vector3(8f, 0.9f, 10f), new Vector3(2f, 1.8f, 1f));

        GameObject lamp = new GameObject("Test Light");
        lamp.transform.rotation = Quaternion.Euler(50f, -35f, 0f);
        Light light = lamp.AddComponent<Light>();
        light.type = LightType.Directional;
        light.intensity = 0.7f;

        GameObject waiting = new GameObject("Waiting Camera");
        waiting.transform.position = new Vector3(0f, 18f, -19f);
        waiting.transform.rotation = Quaternion.Euler(45f, 0f, 0f);
        Camera waitingCamera = waiting.AddComponent<Camera>();
        AudioListener waitingListener = waiting.AddComponent<AudioListener>();

        GameObject playerPrefab = CreatePlayerPrefab();
        if (playerPrefab == null)
        {
            Debug.LogError("Could not create the player prefab.");
            return;
        }

        GameObject managerObject = new GameObject("NetworkManager");
        UnityTransport transport = managerObject.AddComponent<UnityTransport>();
        NetworkManager manager = managerObject.AddComponent<NetworkManager>();
        manager.NetworkConfig.NetworkTransport = transport;
        manager.NetworkConfig.PlayerPrefab = playerPrefab;
        manager.NetworkConfig.EnableSceneManagement = true;

        CoopNetworkDebugUI ui = managerObject.AddComponent<CoopNetworkDebugUI>();
        SerializedObject serializedUI = new SerializedObject(ui);
        serializedUI.FindProperty("waitingCamera").objectReferenceValue = waitingCamera;
        serializedUI.FindProperty("waitingAudioListener").objectReferenceValue = waitingListener;
        serializedUI.ApplyModifiedPropertiesWithoutUndo();

        EditorSceneManager.SaveScene(scene, ScenePath);
        AddSceneToBuildSettings(ScenePath);
        AssetDatabase.SaveAssets();
        Selection.activeGameObject = managerObject;
        Debug.Log("Containment Shift graybox ready: click Host Game in play mode. " +
                  "Use Multiplayer Play Mode or a second build for a local client.");
    }

    private static void CreateBlock(string name, Vector3 position, Vector3 scale)
    {
        GameObject block = GameObject.CreatePrimitive(PrimitiveType.Cube);
        block.name = name;
        block.transform.position = position;
        block.transform.localScale = scale;
    }

    private static GameObject CreatePlayerPrefab()
    {
        GameObject root = new GameObject("NetworkPlayer");
        root.AddComponent<NetworkObject>();
        root.AddComponent<OwnerNetworkTransform>();
        CharacterController controller = root.AddComponent<CharacterController>();
        controller.center = new Vector3(0f, 0.9f, 0f);
        controller.height = 1.8f;
        controller.radius = 0.3f;
        controller.stepOffset = 0.3f;

        GameObject body = GameObject.CreatePrimitive(PrimitiveType.Capsule);
        body.name = "LowPolyBody";
        body.transform.SetParent(root.transform, false);
        body.transform.localPosition = new Vector3(0f, 0.9f, 0f);
        body.transform.localScale = new Vector3(0.75f, 0.9f, 0.75f);
        Object.DestroyImmediate(body.GetComponent<Collider>());

        GameObject pivot = new GameObject("CameraPivot");
        pivot.transform.SetParent(root.transform, false);
        pivot.transform.localPosition = new Vector3(0f, 1.6f, 0f);

        GameObject cameraObject = new GameObject("PlayerCamera");
        cameraObject.transform.SetParent(pivot.transform, false);
        Camera playerCamera = cameraObject.AddComponent<Camera>();
        playerCamera.fieldOfView = 75f;
        AudioListener playerListener = cameraObject.AddComponent<AudioListener>();

        PlayerMovementSettings settings = AssetDatabase.LoadAssetAtPath<PlayerMovementSettings>(SettingsPath);
        if (settings == null)
        {
            settings = ScriptableObject.CreateInstance<PlayerMovementSettings>();
            AssetDatabase.CreateAsset(settings, SettingsPath);
        }

        CoopPlayerMotor motor = root.AddComponent<CoopPlayerMotor>();
        SerializedObject serializedMotor = new SerializedObject(motor);
        serializedMotor.FindProperty("movementSettings").objectReferenceValue = settings;
        serializedMotor.FindProperty("cameraPivot").objectReferenceValue = pivot.transform;
        serializedMotor.FindProperty("playerCamera").objectReferenceValue = playerCamera;
        serializedMotor.FindProperty("playerAudioListener").objectReferenceValue = playerListener;
        serializedMotor.ApplyModifiedPropertiesWithoutUndo();

        GameObject prefab = PrefabUtility.SaveAsPrefabAsset(root, PrefabPath);
        Object.DestroyImmediate(root);
        return prefab;
    }

    private static void AddSceneToBuildSettings(string path)
    {
        EditorBuildSettingsScene[] existing = EditorBuildSettings.scenes;
        foreach (EditorBuildSettingsScene entry in existing)
        {
            if (entry.path == path) return;
        }

        EditorBuildSettingsScene[] updated = new EditorBuildSettingsScene[existing.Length + 1];
        for (int i = 0; i < existing.Length; i++) updated[i] = existing[i];
        updated[existing.Length] = new EditorBuildSettingsScene(path, true);
        EditorBuildSettings.scenes = updated;
    }
}
#endif
