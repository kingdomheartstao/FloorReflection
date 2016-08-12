/* 
	VertexDirt plug-in for Unity
	Copyright 2014-2015, Zoltan Farago, All rights reserved.
*/
static class VDPass {

	var vertexSample : VertexSample = new VertexSample();
	var sampleWidth : int = 64;
	var sampleHeight : int = 64;
	var samplingBias : float = 0.001;
	var samplingDistance : float = 100;
	var samplingAngle : float = 100;
	var edgeSmooth : boolean = false;
	var invertNormals : boolean = false;
	var edgeSmoothBias : float = 0.001;
	var skyMode : CameraClearFlags = CameraClearFlags.SolidColor;
	var disableOccluders : boolean = false;
	var skyColor : Color = Color.white;
	var globalOccluderColor : Color = Color.black;
	var indirectIntensity : float = 1.0;
	var indirectContrast : float = 1.0;
	var occluderShader : String = VDSHADER.AMBIENTOCCLUSION;
	var skyCube : Material;

}
