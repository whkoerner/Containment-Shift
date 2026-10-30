using Unity.Netcode;
using UnityEngine;
using UnityEngine.InputSystem;

/// <summary>
/// Minimal networked first-person movement using Unity's new Input System.
/// Only the owning client reads input or moves its CharacterController.
/// </summary>
[RequireComponent(typeof(NetworkObject))]
[RequireComponent(typeof(OwnerNetworkTransform))]
[RequireComponent(typeof(CharacterController))]
public sealed class CoopPlayerMotor : NetworkBehaviour
{
    [Header("Tuning")]
    [SerializeField] private PlayerMovementSettings movementSettings;

    [Header("View")]
    [SerializeField] private Transform cameraPivot;
    [SerializeField] private Camera playerCamera;
    [SerializeField] private AudioListener playerAudioListener;

    private CharacterController controller;
    private float verticalVelocity;
    private float pitch;
    private bool cursorLocked;

    private void Awake()
    {
        controller = GetComponent<CharacterController>();

        if (playerCamera == null)
        {
            playerCamera = GetComponentInChildren<Camera>(true);
        }

        if (playerCamera != null && cameraPivot == null)
        {
            cameraPivot = playerCamera.transform.parent;
        }

        if (playerCamera != null && playerAudioListener == null)
        {
            playerAudioListener = playerCamera.GetComponent<AudioListener>();
        }

        // A remote player's camera and collider must not affect this client's view.
        controller.enabled = false;
        if (playerCamera != null) playerCamera.enabled = false;
        if (playerAudioListener != null) playerAudioListener.enabled = false;
    }

    public override void OnNetworkSpawn()
    {
        base.OnNetworkSpawn();
        if (!IsOwner) return;
        if (movementSettings == null)
        {
            Debug.LogError("Assign PlayerMovementSettings to the NetworkPlayer prefab.", this);
            return;
        }

        // Spread players apart in the test arena (prototype spawn positions).
        transform.position = new Vector3((OwnerClientId % 4) * 2.5f - 3.75f, 0f, 0f);
        controller.enabled = true;
        if (playerCamera != null) playerCamera.enabled = true;
        if (playerAudioListener != null) playerAudioListener.enabled = true;
        SetCursorLocked(true);
    }

    private void Update()
    {
        if (!IsSpawned || !IsOwner || !controller.enabled || movementSettings == null) return;

        Keyboard keyboard = Keyboard.current;
        if (keyboard != null && keyboard.escapeKey.wasPressedThisFrame)
        {
            SetCursorLocked(false);
        }
        else if (!cursorLocked && Mouse.current != null &&
                 Mouse.current.leftButton.wasPressedThisFrame)
        {
            SetCursorLocked(true);
        }

        UpdateView();
        UpdateMovement(keyboard);
    }

    private void UpdateView()
    {
        if (!cursorLocked || Mouse.current == null || cameraPivot == null) return;

        Vector2 delta = Mouse.current.delta.ReadValue() * movementSettings.MouseSensitivity;
        transform.Rotate(0f, delta.x, 0f, Space.Self);
        pitch = Mathf.Clamp(pitch - delta.y, -85f, 85f);
        cameraPivot.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }

    private void UpdateMovement(Keyboard keyboard)
    {
        Vector2 input = Vector2.zero;
        if (keyboard != null)
        {
            if (keyboard.wKey.isPressed) input.y += 1f;
            if (keyboard.sKey.isPressed) input.y -= 1f;
            if (keyboard.dKey.isPressed) input.x += 1f;
            if (keyboard.aKey.isPressed) input.x -= 1f;
        }

        input = Vector2.ClampMagnitude(input, 1f);
        bool sprint = keyboard != null && keyboard.leftShiftKey.isPressed;
        float speed = sprint ? movementSettings.SprintSpeed : movementSettings.WalkSpeed;
        Vector3 direction = transform.TransformDirection(new Vector3(input.x, 0f, input.y));

        if (controller.isGrounded && verticalVelocity < 0f)
        {
            verticalVelocity = -2f;
        }
        if (controller.isGrounded && keyboard != null && keyboard.spaceKey.wasPressedThisFrame)
        {
            verticalVelocity = Mathf.Sqrt(movementSettings.JumpHeight * -2f * movementSettings.Gravity);
        }

        verticalVelocity += movementSettings.Gravity * Time.deltaTime;
        Vector3 motion = direction * speed + Vector3.up * verticalVelocity;
        controller.Move(motion * Time.deltaTime);
    }

    private void SetCursorLocked(bool locked)
    {
        cursorLocked = locked;
        Cursor.lockState = locked ? CursorLockMode.Locked : CursorLockMode.None;
        Cursor.visible = !locked;
    }

    public override void OnNetworkDespawn()
    {
        if (IsOwner) SetCursorLocked(false);
        if (playerCamera != null) playerCamera.enabled = false;
        if (playerAudioListener != null) playerAudioListener.enabled = false;
        if (controller != null) controller.enabled = false;
        base.OnNetworkDespawn();
    }
}
