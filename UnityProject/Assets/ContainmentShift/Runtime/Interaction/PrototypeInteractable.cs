using UnityEngine;

namespace ContainmentShift.Interaction
{
    // Local prototype view only. Do NOT make this the network authority API.
    // Phase 1C will route intent to an authoritative application command.
    public abstract class PrototypeInteractable : MonoBehaviour
    {
        public abstract string Prompt { get; }
        public abstract void Interact(PrototypeInteractor interactor);
    }
}

