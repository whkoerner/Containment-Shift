using UnityEngine;
using UnityEngine.InputSystem;

namespace ContainmentShift.Player
{
    [RequireComponent(typeof(CharacterController))]
    public sealed class PrototypePlayerMotor : MonoBehaviour
    {
        [SerializeField] private Transform viewPitchPivot;
        [SerializeField] private float walkSpeed = 4.5f;
        [SerializeField] private float mouseSensitivity = 0.12f;
        [SerializeField] private float gravity = -23f;
        [SerializeField] private float jumpSpeed = 6f;

        private CharacterController controller;
        private float verticalSpeed;
        private float pitch;

        private void Awake()
        {
            controller = GetComponent<CharacterController>();
            if (viewPitchPivot == null)
            {
                Debug.LogError("PrototypePlayerMotor requires a camera pivot.", this);
                enabled = false;
            }
        }

        public void Configure(Transform pivot) => viewPitchPivot = pivot;

        private void Update()
        {
            Keyboard keyboard = Keyboard.current;
            Mouse mouse = Mouse.current;
            if (keyboard == null) return;

            if (keyboard.escapeKey.wasPressedThisFrame)
                Cursor.lockState = CursorLockMode.None;

            if (mouse != null && mouse.leftButton.wasPressedThisFrame)
                Cursor.lockState = CursorLockMode.Locked;

            if (Cursor.lockState == CursorLockMode.Locked && mouse != null)
            {
                Vector2 delta = mouse.delta.ReadValue() * mouseSensitivity;
                transform.Rotate(0f, delta.x, 0f);
                pitch = Mathf.Clamp(pitch - delta.y, -85f, 85f);
                viewPitchPivot.localRotation = Quaternion.Euler(pitch, 0f, 0f);
            }

            float strafe = (keyboard.dKey.isPressed ? 1f : 0f) - (keyboard.aKey.isPressed ? 1f : 0f);
            float forward = (keyboard.wKey.isPressed ? 1f : 0f) - (keyboard.sKey.isPressed ? 1f : 0f);
            Vector3 localMove = Vector3.ClampMagnitude(new Vector3(strafe, 0f, forward), 1f);
            Vector3 horizontal = transform.TransformDirection(localMove) * walkSpeed;

            if (controller.isGrounded)
            {
                if (verticalSpeed < 0f) verticalSpeed = -2f;
                if (keyboard.spaceKey.wasPressedThisFrame) verticalSpeed = jumpSpeed;
            }

            verticalSpeed += gravity * Time.deltaTime;
            controller.Move((horizontal + Vector3.up * verticalSpeed) * Time.deltaTime);
        }
    }
}

