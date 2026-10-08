using UnityEngine;
using ContainmentShift.Interaction;

namespace ContainmentShift.World
{
    // Child panel collider rotates with this hinge. Networked doors will be driven
    // by authoritative discrete state, not this local toggle method.
    public sealed class PrototypeDoor : PrototypeInteractable
    {
        [SerializeField] private float openingDegrees = 95f;
        [SerializeField] private float degreesPerSecond = 135f;
        private Quaternion closedRotation;
        private bool isOpen;

        private void Awake() => closedRotation = transform.localRotation;

        public override string Prompt => isOpen ? "close door" : "open door";

        public override void Interact(PrototypeInteractor interactor) => isOpen = !isOpen;

        private void Update()
        {
            Quaternion target = closedRotation * Quaternion.Euler(0f, isOpen ? openingDegrees : 0f, 0f);
            transform.localRotation = Quaternion.RotateTowards(transform.localRotation, target,
                degreesPerSecond * Time.deltaTime);
        }
    }
}

