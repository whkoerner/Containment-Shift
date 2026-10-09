using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;
using ContainmentShift.Interaction;
using ContainmentShift.Player;
using ContainmentShift.World;

namespace ContainmentShift.Editor
{
    public static class Phase1SceneGenerator
    {
        public const string ScenePath = "Assets/ContainmentShift/Scenes/Phase1Graybox.unity";

        [MenuItem("Containment Shift/Generate Phase 1 Graybox Scene")]
        public static void Generate()
        {
            if (AssetDatabase.LoadAssetAtPath<SceneAsset>(ScenePath) != null)
            {
                EditorUtility.DisplayDialog("Containment Shift",
                    "Scene already exists. It was not overwritten. Open it from Assets/ContainmentShift/Scenes.", "OK");
                return;
            }

            if (!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) return;
            Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            EnsureFolders();
            MakeCube("Concrete floor", new Vector3(0f, -.25f, 0f), new Vector3(20f, .5f, 20f));
            MakeCube("North wall", new Vector3(0f, 2f, 10f), new Vector3(20f, 4f, .5f));
            MakeCube("South wall", new Vector3(0f, 2f, -10f), new Vector3(20f, 4f, .5f));
            MakeCube("West wall", new Vector3(-10f, 2f, 0f), new Vector3(.5f, 4f, 20f));
            MakeCube("East wall", new Vector3(10f, 2f, 0f), new Vector3(.5f, 4f, 20f));
            MakeCube("Bulkhead left", new Vector3(-5.55f, 2f, 2f), new Vector3(8.9f, 4f, .5f));
            MakeCube("Bulkhead right", new Vector3(5.55f, 2f, 2f), new Vector3(8.9f, 4f, .5f));
            MakeCube("Bulkhead lintel", new Vector3(0f, 3.55f, 2f), new Vector3(2.2f, .9f, .5f));

            GameObject hinge = new GameObject("Sliding? NO - hinged test door");
            hinge.transform.position = new Vector3(-1f, 0f, 2f);
            hinge.AddComponent<PrototypeDoor>();
            GameObject panel = MakeCube("Door panel (collider)", new Vector3(0f, 1.5f, 0f),
                new Vector3(1.85f, 3f, .18f));
            panel.transform.SetParent(hinge.transform, false);
            panel.transform.localPosition = new Vector3(.925f, 1.5f, 0f);

            for (int i = 0; i < 12; i++)
            {
                GameObject prop = GameObject.CreatePrimitive(i % 3 == 0 ? PrimitiveType.Sphere : PrimitiveType.Cube);
                prop.name = "PROTOTYPE movable prop " + (i + 1).ToString("00");
                prop.transform.position = new Vector3(-5f + (i % 4) * 2.8f, 1.2f, 4.5f + (i / 4) * 1.65f);
                prop.transform.localScale = Vector3.one * (i % 3 == 0 ? .6f : .8f);
                Rigidbody body = prop.AddComponent<Rigidbody>();
                body.mass = 2f + i;
                prop.AddComponent<PrototypeGrabbable>();
            }

            Light ceiling = CreatePointLight("Cold overhead working light", new Vector3(0f, 3.6f, -2f),
                new Color(.65f, .82f, 1f), true);
            ceiling.intensity = 2200f;
            Light warning = CreatePointLight("RED WARNING LIGHT (switch controlled)", new Vector3(0f, 3.6f, 6f),
                new Color(1f, .08f, .04f), false);
            warning.intensity = 2600f;

            GameObject switchBox = MakeCube("Switch: toggle emergency light", new Vector3(-2f, 1.4f, 1.7f),
                new Vector3(.5f, .55f, .45f));
            switchBox.AddComponent<PrototypeSwitch>().Configure(warning);

            GameObject player = new GameObject("LOCAL PLAYER - not network spawned");
            player.transform.position = new Vector3(0f, .92f, -6f);
            CharacterController character = player.AddComponent<CharacterController>();
            character.height = 1.8f;
            character.radius = .33f;
            character.center = Vector3.zero;
            character.stepOffset = .3f;
            GameObject bodyVisual = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            bodyVisual.name = "Prototype visible torso (no gameplay collider)";
            Object.DestroyImmediate(bodyVisual.GetComponent<CapsuleCollider>());
            bodyVisual.transform.SetParent(player.transform, false);
            bodyVisual.transform.localPosition = new Vector3(0f, -.2f, 0f);
            bodyVisual.transform.localScale = new Vector3(.65f, .55f, .65f);
            GameObject cameraObject = new GameObject("First-person camera pivot");
            cameraObject.transform.SetParent(player.transform, false);
            cameraObject.transform.localPosition = new Vector3(0f, .62f, 0f);
            cameraObject.tag = "MainCamera";
            Camera camera = cameraObject.AddComponent<Camera>();
            camera.fieldOfView = 75f;
            camera.nearClipPlane = .05f;
            cameraObject.AddComponent<AudioListener>();
            player.AddComponent<PrototypePlayerMotor>().Configure(cameraObject.transform);
            player.AddComponent<PrototypeInteractor>().Configure(camera);

            RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
            RenderSettings.ambientLight = new Color(.16f, .18f, .21f);
            EditorSceneManager.SaveScene(scene, ScenePath);
            EditorBuildSettings.scenes = new[] { new EditorBuildSettingsScene(ScenePath, true) };
            AssetDatabase.SaveAssets();
            Selection.activeObject = AssetDatabase.LoadAssetAtPath<SceneAsset>(ScenePath);
            Debug.Log("Containment Shift: saved graybox scene and added it to build scene list. Press Play.");
        }

        private static void EnsureFolders()
        {
            if (!AssetDatabase.IsValidFolder("Assets/ContainmentShift/Scenes"))
                AssetDatabase.CreateFolder("Assets/ContainmentShift", "Scenes");
        }

        private static GameObject MakeCube(string name, Vector3 position, Vector3 scale)
        {
            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.name = name;
            cube.transform.position = position;
            cube.transform.localScale = scale;
            return cube;
        }

        private static Light CreatePointLight(string name, Vector3 location, Color color, bool active)
        {
            GameObject lightObject = new GameObject(name);
            lightObject.transform.position = location;
            Light light = lightObject.AddComponent<Light>();
            light.type = LightType.Point;
            light.range = 15f;
            light.color = color;
            light.enabled = active;
            return light;
        }
    }
}

