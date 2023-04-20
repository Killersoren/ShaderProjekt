using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


public class MyRenderPass : ScriptableRenderPass
{
    private SimplePostProcessEffect effect;

    public MyRenderPass(Material material, float intensity, Color color)
    {
        effect = new SimplePostProcessEffect(material, intensity, color);
    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        effect.Configure(cmd, cameraTextureDescriptor);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        effect.Execute(context, ref renderingData);
    }

    public override void FrameCleanup(CommandBuffer cmd)
    {
        effect.FrameCleanup(cmd);
    }
}
