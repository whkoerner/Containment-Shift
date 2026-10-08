using UnityEngine;
using ContainmentShift.Interaction;

namespace ContainmentShift.World
{
    public sealed class PrototypeSwitch : PrototypeInteractable
    {
        [SerializeField] private Light controlledLight;
        private bool enabledState;

        public void Configure(Light target)
        {
            controlledLight = target;
            enabledState = target != null && target.enabled;
        }

        public override string Prompt => enabledState ? "switch warning OFF" : "switch warning ON";

        public override void Interact(PrototypeInteractor interactor)
        {
            enabledState = !enabledState;
            if (controlledLight != null) controlledLight.enabled = enabledState;
        }
    }
}

