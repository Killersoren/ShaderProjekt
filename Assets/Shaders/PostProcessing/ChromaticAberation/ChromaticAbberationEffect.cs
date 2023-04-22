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
	//	TestMethod();
	}

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		_material.SetFloat(_distanceId, _distance);
		Graphics.Blit(source, destination, _material);
	}

	public void LateUpdate()
	{
		if (_material != null)
			{
			//_material.SetFloat(_distanceId, _distance);
			//_distance = Mathf.PingPong(Time.time, 0.05f);


			    // Update the value of the _distance variable
    		_distance = Mathf.Sin(Time.time);

    		// Update the material with the new value of the _distance variable
			_material.SetFloat(_distanceId, _distance);
			Debug.Log("Resy");
			}
	}

	// public void Update()
	// {
	// 	TestMethod();
	// }

	public void TestMethod()
	{
		Debug.Log("Test metode!!!");
	}
}
