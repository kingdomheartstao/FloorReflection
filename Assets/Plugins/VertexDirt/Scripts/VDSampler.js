/* 
	VertexDirt plug-in for Unity
	Copyright 2014-2015, Zoltan Farago, All rights reserved.
*/
@script ExecuteInEditMode()

function OnPostRender () {

	var tex = new Texture2D (VertexDirt.sampleWidth, VertexDirt.sampleHeight, TextureFormat.RGB24, true);
	tex.ReadPixels (Rect(0, 0, VertexDirt.sampleWidth, VertexDirt.sampleHeight), 0, 0);
	//tex.Apply();
	var lum : Color32[] = tex.GetPixels32(tex.mipmapCount-1);
	//var bytes = tex.EncodeToPNG();
	//System.IO.File.WriteAllBytes(Application.dataPath + "/../SavedScreen"+VertexDirt.vertexSample.index+".png", bytes);	
	DestroyImmediate (tex);
	VertexDirt.SetColorSample(lum[0]);
	
}
