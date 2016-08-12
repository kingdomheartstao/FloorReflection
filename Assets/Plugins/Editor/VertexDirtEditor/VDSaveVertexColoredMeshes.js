/* 
	VertexDirt plug-in for Unity
	Copyright 2014-2015, Zoltan Farago, All rights reserved.
*/
class VDSaveVertexColoredMeshes extends EditorWindow {

	private var path : String = "Plugins/VertexDirt/Saved meshes";
	
	@MenuItem("Tools/VertexDirt/Save Meshes", false, 20)
    
	static function Init() {
	
		var window : VDSaveVertexColoredMeshes = EditorWindow.GetWindow(VDSaveVertexColoredMeshes, false, "Save meshes");
		window.position = Rect(600,200, 400,50);
		window.autoRepaintOnSceneChange = true;
		window.Show();
		
    }
     
    function OnGUI() {
	
		GUILayout.Label("Use this tool after colors generated.");
		GUILayout.Label("Select single GameObject.");
		path = EditorGUILayout.TextField("Asset path for saving: ", path);
		if (GUILayout.Button("Save meshes of children.", GUILayout.Height(40))) {

			//Debug.Log (GetPathName(Selection.activeTransform, ""));
		
			var gos : Transform[] = Selection.activeTransform.GetComponentsInChildren.<Transform>(); 
		
 			for (var t : Transform in gos) {
			
				if (t.gameObject.GetComponent.<VDColorHandlerBase>() && t.gameObject.GetComponent.<MeshFilter>()) {
				
					try {
					
						AssetDatabase.CreateAsset( 
						
							t.gameObject.GetComponent.<MeshFilter>().sharedMesh, "Assets/"+path+"/"+GetPathName(t, "") +".asset" 
							
						);
						
					}
					catch(e : UnityException) {
					
						Debug.Log ("This asset already saved. If you have multiple gameobjects at the same hierarchy and with the same name, please give them uniqe names.");
					
					}
						
					AssetDatabase.SaveAssets();
					t.gameObject.GetComponent.<VDColorHandlerBase>().coloredMesh =
						t.gameObject.GetComponent.<MeshFilter>().sharedMesh;
				
				}
				
			}

			AssetDatabase.Refresh();
			
		}
		
		Repaint();
		
	}
	
	function GetPathName( t : Transform, s : String) : String {
	
		s = t.name + s;
	
		if (t.parent != null) {
			s = "--" + s;
			s = GetPathName(t.parent, s);
			
		}
			
		return s;
	
	}
	
}
