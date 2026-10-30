using UnityEngine;
using UnityEngine.InputSystem;

namespace ContainmentShift.Interaction
{
    public sealed class PrototypeInteractor : MonoBehaviour
    {
        [SerializeField] private Camera viewCamera;
        [SerializeField] private float reach = 3f;
        [SerializeField] private float throwSpeed = 7f;
        private PrototypeInteractable focused;
        private PrototypeGrabbable held;

        public Camera ViewCamera => viewCamera;
        public float Reach => reach;
        public string CurrentPrompt => held != null
            ? "Q: drop  |  F: throw"
            : focused != null ? "E: " + focused.Prompt : "";

        public void Configure(Camera camera) => viewCamera = camera;

        private void Update()
        {
            if (viewCamera == null) return;
            focused = null;
            if (Physics.Raycast(viewCamera.transform.position, viewCamera.transform.forward,
                out RaycastHit hit, reach, ~0, QueryTriggerInteraction.Ignore))
            {
                // Ignore the player body/own collider and do not act through it.
                focused = hit.collider.GetComponentInParent<PrototypeInteractable>();
            }

            Keyboard keyboard = Keyboard.current;
            if (keyboard == null) return;

            if (held != null)
            {
                if (keyboard.qKey.wasPressedThisFrame) ReleaseHeld(false);
                else if (keyboard.fKey.wasPressedThisFrame) ReleaseHeld(true);
            }
            else if (focused != null && keyboard.eKey.wasPressedThisFrame)
            {
                focused.Interact(this);
            }
        }

        public bool TryPickUp(PrototypeGrabbable item)
        {
            if (item == null || held != null || viewCamera == null) return false;
            if (!item.TryAcquire(this, Vector3.Distance(viewCamera.transform.position, item.transform.position), reach))
                return false;
            held = item;
            return true;
        }

        public Vector3 HoldTarget => viewCamera == null ? transform.position :
            viewCamera.transform.position + viewCamera.transform.forward * 1.75f;

        private void ReleaseHeld(bool throwing)
        {
            PrototypeGrabbable item = held;
            held = null;
            if (item != null) item.Release(this, throwing ? viewCamera.transform.forward * throwSpeed : Vector3.zero);
        }

        public void NotifyRemoved(PrototypeGrabbable item)
        {
            if (held == item) held = null;
        }

        private void OnDisable()
        {
            if (held != null) ReleaseHeld(false);
        }

        private void OnGUI()
        {
            if (viewCamera == null || Camera.main != viewCamera) return;
            GUI.Label(new Rect(Screen.width / 2f - 4f, Screen.height / 2f - 12f, 40f, 30f), "+");
            GUI.Box(new Rect(12f, Screen.height - 80f, 380f, 66f),
                "Containment Shift | LOCAL PROTOTYPE\nWASD move  SPACE jump  Click mouse lock  ESC unlock\n" + CurrentPrompt);
        }
    }
}

