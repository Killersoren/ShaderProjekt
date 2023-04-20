using UnityEngine;

[ExecuteAlways]
public class ChromaticAbberationEffect : MonoBehaviour
{
	private static int _distanceId = Shader.PropertyToID("_Distance");

	[SerializeField, Range(0,0.05f)] private float _distance = 0.01f;

	private Material _material;

	private void Awake()
	{
		_material = new Material(Shader.Find("Hidden/ChromaticAbberation"));
	}

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		_material.SetFloat(_distanceId, _distance);
		Graphics.Blit(source, destination, _material);
	}
}
