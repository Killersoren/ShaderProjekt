using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


public class MyRendererFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class MySettings
    {
        public Material material;
        public float intensity = 1.0f;
        public Color color = Color.white;
    }

    public MySettings settings = new MySettings();

    private MyRenderPass renderPass;

    public override void Create()
    {
        renderPass = new MyRenderPass(settings.material, settings.intensity, settings.color);
        renderPass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(renderPass);
    }
}
