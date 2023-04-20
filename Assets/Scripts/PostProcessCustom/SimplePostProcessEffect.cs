using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class SimplePostProcessEffect : ScriptableRenderPass
{
    private Material material;

    private RenderTargetIdentifier source;
    private RenderTargetHandle destination;

    private float intensity;
    private Color color;

    public SimplePostProcessEffect(Material material, float intensity, Color color)
    {
        this.material = material;
        this.intensity = intensity;
        this.color = color;
        destination.Init("_TempTexture");

        renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public void Setup(RenderTargetIdentifier source)
    {
        this.source = source;
    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        cmd.GetTemporaryRT(destination.id, cameraTextureDescriptor);
        ConfigureTarget(destination.Identifier());
        ConfigureClear(ClearFlag.All, Color.clear);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        var cmd = CommandBufferPool.Get();
        cmd.SetGlobalFloat("_Intensity", intensity);
        cmd.SetGlobalColor("_Color", color);
        cmd.SetRenderTarget(destination.Identifier());
        cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, material);

        Blit(cmd, destination.Identifier(), source);
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public override void FrameCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(destination.id);
    }
}
