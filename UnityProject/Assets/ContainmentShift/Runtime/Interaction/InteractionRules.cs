namespace ContainmentShift.Interaction
{
    // Small, pure rule used before a local grab. The authoritative version must
    // additionally validate source connection, world tick, range, and leases.
    public static class InteractionRules
    {
        public static bool CanAcquire(bool alreadyHeld, float mass, float maxMass, float distance, float maxDistance)
        {
            return !alreadyHeld && IsFinite(mass) && IsFinite(maxMass)
                && IsFinite(distance) && IsFinite(maxDistance)
                && mass > 0f && maxMass > 0f && distance >= 0f && maxDistance > 0f
                && mass <= maxMass && distance <= maxDistance;
        }

        private static bool IsFinite(float value)
        {
            return !float.IsNaN(value) && !float.IsInfinity(value);
        }
    }
}

