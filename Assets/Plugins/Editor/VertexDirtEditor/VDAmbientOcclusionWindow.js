/* 
	VertexDirt plug-in for Unity
	Copyright 2014-2015, Zoltan Farago, All rights reserved.
*/
class VDAmbientOcclusionWindow extends EditorWindow {

	@MenuItem ("Tools/VertexDirt/Ambient Occlusion")
	static function ShowWindow () {

		var window : VDAmbientOcclusionWindow = ScriptableObject.CreateInstance.<VDAmbientOcclusionWindow>();
		
		window.position = Rect(100,100, 260,400);
		window.minSize = Vector2 (260,400);
		window.maxSize = Vector2 (260,400);
		window.title = "VD Ambient Occlusion";
		window.ShowUtility();
		VertexDirt.SetPreset (VDPRESET.AMBIENTOCCLUSION);

	}
	
    function OnGUI() {

		GUILayout.Label ("Occlusion distance");
		VertexDirt.samplingDistance = EditorGUILayout.Slider(VertexDirt.samplingDistance,0.01, 1000.0);
		GUILayout.Space(10);
		GUILayout.BeginHorizontal();
		GUILayout.Label ("Edge smooth enabled");
		GUILayout.FlexibleSpace();
		VertexDirt.edgeSmooth = GUILayout.Toggle(VertexDirt.edgeSmooth, "");
		GUILayout.EndHorizontal();
		GUILayout.Space(10);
		GUILayout.Label ("Sampling angle");
		VertexDirt.samplingAngle = EditorGUILayout.Slider(VertexDirt.samplingAngle,100, 150);
		//		VertexDirt.skyCube = EditorGUILayout.ObjectField(VertexDirt.skyCube, Material, true);
		GUILayout.Space(10);
		GUILayout.Label ("Sky color");
		VertexDirt.skyColor = EditorGUILayout.ColorField(VertexDirt.skyColor);
		GUILayout.Space(10);
		GUILayout.Label ("Shadow color");
		VertexDirt.globalOccluderColor = EditorGUILayout.ColorField(VertexDirt.globalOccluderColor);
		//		globalOccluderColor = Color.black;
		
 		if (Selection.gameObjects) {
		
			if (GUI.Button(Rect(10,350,240,40),"Start") ) {

				var tempTime : float = EditorApplication.timeSinceStartup;
				VertexDirt.Dirt(Selection.GetFiltered(Transform, SelectionMode.Deep));
				Debug.Log ("Dirt time: " + (EditorApplication.timeSinceStartup - tempTime));
		
			}
			
		}
 
    }
	
}