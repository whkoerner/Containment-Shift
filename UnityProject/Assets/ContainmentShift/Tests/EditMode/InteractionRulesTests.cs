using NUnit.Framework;
using ContainmentShift.Interaction;

namespace ContainmentShift.Tests
{
    public class InteractionRulesTests
    {
        [Test]
        public void RejectsAlreadyHeldItem()
        {
            Assert.IsFalse(InteractionRules.CanAcquire(true, 2f, 20f, 1f, 3f));
        }

        [Test]
        public void RejectsOverweightAndOutOfReachItems()
        {
            Assert.IsFalse(InteractionRules.CanAcquire(false, 50f, 20f, 1f, 3f));
            Assert.IsFalse(InteractionRules.CanAcquire(false, 2f, 20f, 4f, 3f));
        }

        [Test]
        public void RejectsNonFiniteInputs()
        {
            Assert.IsFalse(InteractionRules.CanAcquire(false, float.NaN, 20f, 1f, 3f));
            Assert.IsFalse(InteractionRules.CanAcquire(false, 2f, 20f, float.PositiveInfinity, 3f));
        }

        [Test]
        public void AllowsFiniteInRangeLightItem()
        {
            Assert.IsTrue(InteractionRules.CanAcquire(false, 2f, 20f, 1f, 3f));
        }
    }
}

