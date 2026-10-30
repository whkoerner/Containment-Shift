#if UNITY_EDITOR
using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

/// <summary>
/// Called by overnight PowerShell runner. Never claims tests passed unless Unity builds.
/// </summary>
public static class ContainmentShiftBuildAutomation
{
    public static void VerifyAndBuild()
    {
        CoopPrototypeSceneBuilder.EnsureTestScene();
        string scene = "Assets/ContainmentShift/Scenes/Annex_Greybox.unity";
        if (!File.Exists(scene))
            throw new Exception("Required graybox scene was not generated: " + scene);

        string builds = Path.GetFullPath("Builds/Windows");
        Directory.CreateDirectory(builds);
        string exe = Path.Combine(builds, "ContainmentShift.exe");
        if (File.Exists(exe)) File.Delete(exe);
        PlayerSettings.productName = "Containment Shift - Graybox";
        PlayerSettings.companyName = "Containment Shift";
        PlayerSettings.SetScriptingBackend(NamedBuildTarget.Standalone, ScriptingImplementation.Mono2x);

        var options = new BuildPlayerOptions
        {
            scenes = new[] { scene },
            locationPathName = exe,
            target = BuildTarget.StandaloneWindows64,
            options = BuildOptions.Development
        };
        BuildReport report = BuildPipeline.BuildPlayer(options);
        if (report == null || report.summary.result != BuildResult.Succeeded || !File.Exists(exe))
        {
            throw new Exception("BUILD FAILED. Read the Unity log for compilation/build errors.");
        }
        Debug.Log("CONTAINMENT_SHIFT_BUILD_SUCCEEDED " + exe);
    }
}
#endif
