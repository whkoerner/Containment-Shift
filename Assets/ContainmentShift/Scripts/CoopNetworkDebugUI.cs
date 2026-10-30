using Unity.Netcode;
using Unity.Netcode.Transports.UTP;
using UnityEngine;

/// <summary>
/// Temporary on-screen Host / Join buttons for testing on one machine.
/// Replace with a real menu and Relay sessions in a later phase.
/// </summary>
[RequireComponent(typeof(NetworkManager))]
[RequireComponent(typeof(UnityTransport))]
public sealed class CoopNetworkDebugUI : MonoBehaviour
{
    [SerializeField] private string address = "127.0.0.1";
    [SerializeField] private int port = 7777;
    [SerializeField] private Camera waitingCamera;
    [SerializeField] private AudioListener waitingAudioListener;

    private NetworkManager networkManager;
    private UnityTransport transport;

    private void Awake()
    {
        networkManager = GetComponent<NetworkManager>();
        transport = GetComponent<UnityTransport>();
    }

    private void Update()
    {
        bool waiting = !networkManager.IsListening;
        if (waitingCamera != null && waitingCamera.enabled != waiting)
            waitingCamera.enabled = waiting;
        if (waitingAudioListener != null && waitingAudioListener.enabled != waiting)
            waitingAudioListener.enabled = waiting;
    }

    private void OnGUI()
    {
        if (networkManager == null) return;

        GUILayout.BeginArea(new Rect(12, 12, 260, 144), GUI.skin.box);
        GUILayout.Label("CO-OP HORROR - LOCAL TEST");

        if (!networkManager.IsListening)
        {
            if (GUILayout.Button("Host Game"))
            {
                HideWaitingCamera();
                transport.SetConnectionData(address, (ushort)Mathf.Clamp(port, 1, 65535), "0.0.0.0");
                if (!networkManager.StartHost()) Debug.LogError("StartHost failed.");
            }
            if (GUILayout.Button("Join Local Host"))
            {
                HideWaitingCamera();
                transport.SetConnectionData(address, (ushort)Mathf.Clamp(port, 1, 65535));
                if (!networkManager.StartClient()) Debug.LogError("StartClient failed.");
            }
        }
        else
        {
            GUILayout.Label(networkManager.IsHost ? "Connected: HOST" : "Connected: CLIENT");
            if (GUILayout.Button("Disconnect")) networkManager.Shutdown();
        }

        GUILayout.EndArea();
    }

    private void HideWaitingCamera()
    {
        if (waitingCamera != null) waitingCamera.enabled = false;
        if (waitingAudioListener != null) waitingAudioListener.enabled = false;
    }
}
