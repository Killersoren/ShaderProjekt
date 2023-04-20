using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[CustomEditor(typeof(UniversalRenderPipelineAsset))]
public class CustomRenderPassEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        EditorGUILayout.Space();
        EditorGUILayout.Space();

        GUILayout.Label("Custom Render Passes", EditorStyles.boldLabel);

        if (GUILayout.Button("Add MyRenderPass"))
        {
            var asset = (UniversalRenderPipelineAsset)target;

            var postProcessMaterial = AssetDatabase.LoadAssetAtPath<Material>("Assets/Shaders/PostProcessing/PostProcessExamples/Custom_VignetteEffect.mat");

            var renderPass = new MyRenderPass(postProcessMaterial, 1.5f, Color.blue);

            var renderer = asset.scriptableRendererData.renderer;
            renderer.EnqueuePass(renderPass);

            // Add MyRendererFeature to the pipeline
            var features = asset.scriptableRendererData.rendererFeatures;
            var myRendererFeature = new MyRendererFeature();
            features.Add(myRendererFeature);
        }
    }
}
