// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hidden/BOXOPHOBIC/Atmospherics/Height Fog Global"
{
	Properties
	{
		[StyledCategory(Fog)]_FogCat("[ Fog Cat]", Float) = 1
		[Enum(X Axis,0,Y Axis,1,Z Axis,2)][Space(10)]_FogAxisMode("Fog Axis Mode", Float) = 1
		[StyledCategory(Skybox)]_SkyboxCat("[ Skybox Cat ]", Float) = 1
		[StyledCategory(Directional)]_DirectionalCat("[ Directional Cat ]", Float) = 1
		[StyledCategory(Noise)]_NoiseCat("[ Noise Cat ]", Float) = 1
		[HideInInspector]_HeightFogGlobal("_HeightFogGlobal", Float) = 1
		[HideInInspector]_IsHeightFogShader("_IsHeightFogShader", Float) = 1
		[StyledBanner(Height Fog Global)]_Banner("[ Banner ]", Float) = 1

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Overlay" "Queue"="Overlay" }
	LOD 0

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Front
		ColorMask RGBA
		ZWrite Off
		ZTest Always
		Stencil
		{
			Ref 222
			Comp NotEqual
			Pass Zero
		}
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" "PreviewType"="Skybox" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			//AHF_DISABLE_DIRECTIONAL
			//AHF_DISABLE_NOISE3D


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform half _IsHeightFogShader;
			uniform half _HeightFogGlobal;
			uniform half _Banner;
			uniform half _FogCat;
			uniform half _DirectionalCat;
			uniform half _SkyboxCat;
			uniform half _FogAxisMode;
			uniform half _NoiseCat;
			uniform half4 AHF_FogColorStart;
			uniform half4 AHF_FogColorEnd;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform half AHF_FogDistanceStart;
			uniform half AHF_FogDistanceEnd;
			uniform half AHF_FogDistanceFalloff;
			uniform half AHF_FogColorDuo;
			uniform half4 AHF_DirectionalColor;
			uniform half3 AHF_DirectionalDir;
			uniform half AHF_DirectionalIntensity;
			uniform half AHF_DirectionalFalloff;
			uniform half3 AHF_FogAxisOption;
			uniform half AHF_FogHeightEnd;
			uniform half AHF_FogHeightStart;
			uniform half AHF_FogHeightFalloff;
			uniform half AHF_FogLayersMode;
			uniform half AHF_NoiseScale;
			uniform half3 AHF_NoiseSpeed;
			uniform half AHF_NoiseDistanceEnd;
			uniform half AHF_NoiseIntensity;
			uniform half AHF_SkyboxFogHeight;
			uniform half AHF_SkyboxFogFalloff;
			uniform half AHF_SkyboxFogFill;
			uniform half AHF_SkyboxFogIntensity;
			uniform half AHF_FogIntensity;
			float4 mod289( float4 x )
			{
				return x - floor(x * (1.0 / 289.0)) * 289.0;
			}
			
			float4 perm( float4 x )
			{
				return mod289(((x * 34.0) + 1.0) * x);
			}
			
			float SimpleNoise3D( float3 p )
			{
				    float3 a = floor(p);
				    float3 d = p - a;
				    d = d * d * (3.0 - 2.0 * d);
				    float4 b = a.xxyy + float4(0.0, 1.0, 0.0, 1.0);
				    float4 k1 = perm(b.xyxy);
				    float4 k2 = perm(k1.xyxy + b.zzww);
				    float4 c = k2 + a.zzzz;
				    float4 k3 = perm(c);
				    float4 k4 = perm(c + 1.0);
				    float4 o1 = frac(k3 * (1.0 / 41.0));
				    float4 o2 = frac(k4 * (1.0 / 41.0));
				    float4 o3 = o2 * d.z + o1 * (1.0 - d.z);
				    float2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);
				    return o4.y * d.y + o4.x * (1.0 - d.y);
			}
			
			float2 UnStereo( float2 UV )
			{
				#if UNITY_SINGLE_PASS_STEREO
				float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex];
				UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
				#endif
				return UV;
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 normalizeResult318_g931 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
				float dotResult145_g931 = dot( normalizeResult318_g931 , AHF_DirectionalDir );
				float vertexToFrag438_g931 = pow( abs( ( (dotResult145_g931*0.5 + 0.5) * AHF_DirectionalIntensity ) ) , AHF_DirectionalFalloff );
				o.ase_texcoord2.x = vertexToFrag438_g931;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.yzw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float4 screenPos = i.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 UV235_g931 = ase_screenPosNorm.xy;
				float2 localUnStereo235_g931 = UnStereo( UV235_g931 );
				float2 break248_g931 = localUnStereo235_g931;
				float clampDepth227_g931 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch250_g931 = ( 1.0 - clampDepth227_g931 );
				#else
				float staticSwitch250_g931 = clampDepth227_g931;
				#endif
				float3 appendResult244_g931 = (float3(break248_g931.x , break248_g931.y , staticSwitch250_g931));
				float4 appendResult220_g931 = (float4((appendResult244_g931*2.0 + -1.0) , 1.0));
				float4 break229_g931 = mul( unity_CameraInvProjection, appendResult220_g931 );
				float3 appendResult237_g931 = (float3(break229_g931.x , break229_g931.y , break229_g931.z));
				float4 appendResult233_g931 = (float4(( ( appendResult237_g931 / break229_g931.w ) * half3(1,1,-1) ) , 1.0));
				float4 break245_g931 = mul( unity_CameraToWorld, appendResult233_g931 );
				float3 appendResult239_g931 = (float3(break245_g931.x , break245_g931.y , break245_g931.z));
				float3 WorldPositionFromDepth253_g931 = appendResult239_g931;
				float3 WorldPosition2_g931 = WorldPositionFromDepth253_g931;
				float temp_output_7_0_g936 = AHF_FogDistanceStart;
				half FogDistanceMask12_g931 = pow( abs( saturate( ( ( distance( WorldPosition2_g931 , _WorldSpaceCameraPos ) - temp_output_7_0_g936 ) / ( AHF_FogDistanceEnd - temp_output_7_0_g936 ) ) ) ) , AHF_FogDistanceFalloff );
				float3 lerpResult258_g931 = lerp( (AHF_FogColorStart).rgb , (AHF_FogColorEnd).rgb , ( saturate( ( FogDistanceMask12_g931 - 0.5 ) ) * AHF_FogColorDuo ));
				float vertexToFrag438_g931 = i.ase_texcoord2.x;
				float DirectionalMask30_g931 = vertexToFrag438_g931;
				float3 lerpResult40_g931 = lerp( lerpResult258_g931 , (AHF_DirectionalColor).rgb , DirectionalMask30_g931);
				#ifdef AHF_DISABLE_DIRECTIONAL
				float3 staticSwitch442_g931 = lerpResult258_g931;
				#else
				float3 staticSwitch442_g931 = lerpResult40_g931;
				#endif
				float3 temp_output_2_0_g937 = staticSwitch442_g931;
				float3 gammaToLinear3_g937 = GammaToLinearSpace( temp_output_2_0_g937 );
				#ifdef UNITY_COLORSPACE_GAMMA
				float3 staticSwitch1_g937 = temp_output_2_0_g937;
				#else
				float3 staticSwitch1_g937 = gammaToLinear3_g937;
				#endif
				float3 temp_output_256_0_g931 = staticSwitch1_g937;
				half3 AHF_FogAxisOption181_g931 = AHF_FogAxisOption;
				float3 break159_g931 = ( WorldPosition2_g931 * AHF_FogAxisOption181_g931 );
				float temp_output_7_0_g934 = AHF_FogHeightEnd;
				half FogHeightMask16_g931 = pow( abs( saturate( ( ( ( break159_g931.x + break159_g931.y + break159_g931.z ) - temp_output_7_0_g934 ) / ( AHF_FogHeightStart - temp_output_7_0_g934 ) ) ) ) , AHF_FogHeightFalloff );
				float lerpResult328_g931 = lerp( ( FogDistanceMask12_g931 * FogHeightMask16_g931 ) , saturate( ( FogDistanceMask12_g931 + FogHeightMask16_g931 ) ) , AHF_FogLayersMode);
				float mulTime204_g931 = _Time.y * 2.0;
				float3 temp_output_197_0_g931 = ( ( WorldPosition2_g931 * ( 1.0 / AHF_NoiseScale ) ) + ( -AHF_NoiseSpeed * mulTime204_g931 ) );
				float3 p1_g933 = temp_output_197_0_g931;
				float localSimpleNoise3D1_g933 = SimpleNoise3D( p1_g933 );
				float temp_output_7_0_g932 = AHF_NoiseDistanceEnd;
				half NoiseDistanceMask7_g931 = saturate( ( ( distance( WorldPosition2_g931 , _WorldSpaceCameraPos ) - temp_output_7_0_g932 ) / ( 0.0 - temp_output_7_0_g932 ) ) );
				float lerpResult198_g931 = lerp( 1.0 , (localSimpleNoise3D1_g933*0.5 + 0.5) , ( NoiseDistanceMask7_g931 * AHF_NoiseIntensity ));
				half NoiseSimplex3D24_g931 = lerpResult198_g931;
				#ifdef AHF_DISABLE_NOISE3D
				float staticSwitch42_g931 = lerpResult328_g931;
				#else
				float staticSwitch42_g931 = ( lerpResult328_g931 * NoiseSimplex3D24_g931 );
				#endif
				float3 normalizeResult169_g931 = normalize( ( WorldPosition2_g931 - _WorldSpaceCameraPos ) );
				float3 break170_g931 = ( normalizeResult169_g931 * AHF_FogAxisOption181_g931 );
				float temp_output_7_0_g935 = AHF_SkyboxFogHeight;
				float saferPower309_g931 = max( abs( saturate( ( ( abs( ( break170_g931.x + break170_g931.y + break170_g931.z ) ) - temp_output_7_0_g935 ) / ( 0.0 - temp_output_7_0_g935 ) ) ) ) , 0.0001 );
				float lerpResult179_g931 = lerp( pow( saferPower309_g931 , AHF_SkyboxFogFalloff ) , 1.0 , AHF_SkyboxFogFill);
				half SkyboxFogHeightMask108_g931 = ( lerpResult179_g931 * AHF_SkyboxFogIntensity );
				float clampDepth118_g931 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch123_g931 = clampDepth118_g931;
				#else
				float staticSwitch123_g931 = ( 1.0 - clampDepth118_g931 );
				#endif
				half SkyboxMask95_g931 = ( 1.0 - ceil( staticSwitch123_g931 ) );
				float lerpResult112_g931 = lerp( staticSwitch42_g931 , SkyboxFogHeightMask108_g931 , SkyboxMask95_g931);
				float temp_output_43_0_g931 = ( lerpResult112_g931 * AHF_FogIntensity );
				float4 appendResult114_g931 = (float4(temp_output_256_0_g931 , temp_output_43_0_g931));
				
				
				finalColor = appendResult114_g931;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "HeightFogShaderGUI"
	
	
}
/*ASEBEGIN
Version=18800
1920;13;1906;1009;4019.594;5119.538;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;885;-2912,-4864;Half;False;Property;_IsHeightFogShader;_IsHeightFogShader;32;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;879;-3136,-4864;Half;False;Property;_HeightFogGlobal;_HeightFogGlobal;31;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;892;-3328,-4864;Half;False;Property;_Banner;[ Banner ];33;0;Create;True;0;0;0;True;1;StyledBanner(Height Fog Global);False;1;1;1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1038;-3328,-4608;Inherit;False;Base;0;;931;13c50910e5b86de4097e1181ba121e0e;26,355,0,361,0,347,0,382,0,370,0,372,0,368,0,392,0,343,0,366,0,345,0,364,0,360,0,354,0,116,1,351,0,378,0,380,0,388,0,339,0,384,0,99,1,386,0,349,0,376,0,374,0;0;4;FLOAT4;113;FLOAT3;86;FLOAT;87;FLOAT;445
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;383;-3072,-4608;Float;False;True;-1;2;HeightFogShaderGUI;0;1;Hidden/BOXOPHOBIC/Atmospherics/Height Fog Global;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;1;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;True;222;False;-1;255;False;-1;255;False;-1;6;False;-1;2;False;-1;0;False;-1;0;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;594;True;7;False;595;True;False;0;False;500;1000;False;500;True;2;RenderType=Overlay=RenderType;Queue=Overlay=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;LightMode=ForwardBase;PreviewType=Skybox;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;880;-3328,-4992;Inherit;False;919.8825;100;Drawers;0;;1,0.475862,0,1;0;0
WireConnection;383;0;1038;113
ASEEND*/
//CHKSM=1321CFFB53528861C4655083DF387941CBF5A0EE