using UnityEngine;

namespace ContainmentShift.Interaction
{
    [RequireComponent(typeof(Rigidbody))]
    public sealed class PrototypeGrabbable : PrototypeInteractable
    {
        [SerializeField] private float maxCarryMassKg = 35f;
        [SerializeField] private float followGain = 14f;
        [SerializeField] private float maxFollowSpeed = 9f;
        private Rigidbody body;
        private PrototypeInteractor holder;

        public override string Prompt => "pick up";

        private void Awake() => body = GetComponent<Rigidbody>();

        public override void Interact(PrototypeInteractor interactor)
        {
            interactor.TryPickUp(this);
        }

        public bool TryAcquire(PrototypeInteractor requestedHolder, float distance, float reach)
        {
            if (body == null || requestedHolder == null ||
                !InteractionRules.CanAcquire(holder != null, body.mass, maxCarryMassKg, distance, reach))
                return false;
            holder = requestedHolder;
            body.useGravity = true;
            return true;
        }

        private void FixedUpdate()
        {
            if (holder == null || body == null) return;
            // Force-free local velocity servo: collision is still solved by PhysX.
            // This is explicitly NOT synchronized and cannot apply gameplay damage.
            Vector3 delta = holder.HoldTarget - body.position;
            body.linearVelocity = Vector3.ClampMagnitude(delta * followGain, maxFollowSpeed);
            if (delta.sqrMagnitude > 25f) Release(holder, Vector3.zero);
        }

        public void Release(PrototypeInteractor requestedHolder, Vector3 throwVelocity)
        {
            if (holder != requestedHolder || body == null) return;
            holder = null;
            body.linearVelocity += Vector3.ClampMagnitude(throwVelocity, 8f);
        }

        private void OnDisable()
        {
            if (holder == null) return;
            PrototypeInteractor oldHolder = holder;
            holder = null;
            oldHolder.NotifyRemoved(this);
        }
    }
}

