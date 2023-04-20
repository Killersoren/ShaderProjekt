using UnityEngine;

[ExecuteAlways]
public class ColorAdjustmentEffect : MonoBehaviour
{
    private const string SaturationKeyword = "_Saturation";
    private const string BrightnessKeyword = "_Brightness";
    private const string ContrastKeyword = "_Contrast";

    [SerializeField] private Material _colorAdjustmentMaterial = null;
    [SerializeField, Range(0, 2)] private float _saturation = 1;
    [SerializeField, Range(0, 1)] private float _brightness = 0;
    [SerializeField, Range(0, 2)] private float _contrast = 1;

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        _colorAdjustmentMaterial.SetFloat(SaturationKeyword, _saturation);
        _colorAdjustmentMaterial.SetFloat(ContrastKeyword, _contrast);
        _colorAdjustmentMaterial.SetFloat(BrightnessKeyword, _brightness);
        Graphics.Blit(src, dst, _colorAdjustmentMaterial);
    }
}
