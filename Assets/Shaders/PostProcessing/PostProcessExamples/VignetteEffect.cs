using UnityEngine;

[ExecuteAlways]
public class VignetteEffect : MonoBehaviour
{
    private const string ColorKeyword = "_Color";
    private const string StrengthKeyword = "_Strength";
    private const string SizeKeyword = "_Size";

    [SerializeField] private Material _vignetteMaterial = null;
    [SerializeField] private Color _color = Color.black;
    [SerializeField, Range(0, 1)] private float _size = 1;
    [SerializeField, Range(0, 1)] private float _strength = 1;

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        if (_vignetteMaterial == null)
        {
            return;
        }

        _vignetteMaterial.SetColor(ColorKeyword, _color);
        _vignetteMaterial.SetFloat(StrengthKeyword, _strength);
        _vignetteMaterial.SetFloat(SizeKeyword, _size);
        Graphics.Blit(src, dst, _vignetteMaterial);
    }
}
