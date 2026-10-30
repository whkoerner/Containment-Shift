using UnityEngine;

/// <summary>
/// Player tuning asset; edit one asset to update all players' movement values.
/// </summary>
[CreateAssetMenu(fileName = "PlayerMovementSettings", menuName = "Co-op Horror/Player Movement Settings")]
public sealed class PlayerMovementSettings : ScriptableObject
{
    [SerializeField, Min(0.1f)] private float walkSpeed = 4f;
    [SerializeField, Min(0.1f)] private float sprintSpeed = 6f;
    [SerializeField, Min(0f)] private float jumpHeight = 1.1f;
    [SerializeField] private float gravity = -19.62f;
    [SerializeField, Min(0.01f)] private float mouseSensitivity = 0.12f;

    public float WalkSpeed => walkSpeed;
    public float SprintSpeed => sprintSpeed;
    public float JumpHeight => jumpHeight;
    public float Gravity => gravity;
    public float MouseSensitivity => mouseSensitivity;
}
