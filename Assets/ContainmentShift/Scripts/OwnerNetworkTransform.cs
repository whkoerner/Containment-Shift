using Unity.Netcode.Components;
using UnityEngine;

/// <summary>
/// Prototype-only: the owning player controls their transform.
/// Enemies and destructible objects should use server authority instead.
/// </summary>
[DisallowMultipleComponent]
public sealed class OwnerNetworkTransform : NetworkTransform
{
    protected override bool OnIsServerAuthoritative()
    {
        return false;
    }
}
