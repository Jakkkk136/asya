// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BOXOPHOBIC/Atmospherics/Height Fog Standalone"
{
	Properties
	{
		[StyledBanner(Height Fog Standalone)]_Banner("Banner", Float) = 0
		[StyledCategory(Fog, 5, 10)]_FogCat("[ Fog Cat]", Float) = 1
		_FogIntensity("Fog Intensity", Range( 0 , 1)) = 1
		[Enum(X Axis,0,Y Axis,1,Z Axis,2)][Space(10)]_FogAxisMode("Fog Axis Mode", Float) = 1
		[Enum(Multiply Distance and Height,0,Additive Distance and Height,1)]_FogLayersMode("Fog Layers Mode", Float) = 0
		[HDR][Space(10)]_FogColorStart("Fog Color Start", Color) = (0.4411765,0.722515,1,0)
		[HDR]_FogColorEnd("Fog Color End", Color) = (0.4411765,0.722515,1,0)
		_FogColorDuo("Fog Color Duo", Range( 0 , 1)) = 1
		[Space(10)]_FogDistanceStart("Fog Distance Start", Float) = -200
		_FogDistanceEnd("Fog Distance End", Float) = 200
		_FogDistanceFalloff("Fog Distance Falloff", Range( 1 , 8)) = 2
		[Space(10)]_FogHeightStart("Fog Height Start", Float) = 0
		_FogHeightEnd("Fog Height End", Float) = 200
		_FogHeightFalloff("Fog Height Falloff", Range( 1 , 8)) = 2
		[StyledCategory(Skybox)]_SkyboxCat("[ Skybox Cat ]", Float) = 1
		_SkyboxFogIntensity("Skybox Fog Intensity", Range( 0 , 1)) = 0
		_SkyboxFogHeight("Skybox Fog Height", Range( 0 , 1)) = 1
		_SkyboxFogFalloff("Skybox Fog Falloff", Range( 1 , 8)) = 2
		_SkyboxFogFill("Skybox Fog Fill", Range( 0 , 1)) = 0
		[StyledCategory(Directional)]_DirectionalCat("[ Directional Cat ]", Float) = 1
		[HDR]_DirectionalColor("Directional Color", Color) = (1,0.8280286,0.6084906,0)
		_DirectionalIntensity("Directional Intensity", Range( 0 , 1)) = 1
		_DirectionalFalloff("Directional Falloff", Range( 1 , 8)) = 2
		_DirectionalDir("Directional Dir", Vector) = (1,1,1,0)
		[StyledCategory(Noise)]_NoiseCat("[ Noise Cat ]", Float) = 1
		_NoiseIntensity("Noise Intensity", Range( 0 , 1)) = 1
		_NoiseDistanceEnd("Noise Distance End", Float) = 10
		_NoiseScale("Noise Scale", Float) = 30
		_NoiseSpeed("Noise Speed", Vector) = (0.5,0.5,0,0)
		[HideInInspector]_FogAxisOption("_FogAxisOption", Vector) = (0,0,0,0)
		[HideInInspector]_HeightFogStandalone("_HeightFogStandalone", Float) = 1
		[HideInInspector]_IsHeightFogShader("_IsHeightFogShader", Float) = 1

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

			uniform float _Banner;
			uniform half _HeightFogStandalone;
			uniform half _IsHeightFogShader;
			uniform half _FogCat;
			uniform half _DirectionalCat;
			uniform half _SkyboxCat;
			uniform half _FogAxisMode;
			uniform half _NoiseCat;
			uniform half4 _FogColorStart;
			uniform half4 _FogColorEnd;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform half _FogDistanceStart;
			uniform half _FogDistanceEnd;
			uniform half _FogDistanceFalloff;
			uniform half _FogColorDuo;
			uniform half4 _DirectionalColor;
			uniform half3 _DirectionalDir;
			uniform half _DirectionalIntensity;
			uniform half _DirectionalFalloff;
			uniform half3 _FogAxisOption;
			uniform half _FogHeightEnd;
			uniform half _FogHeightStart;
			uniform half _FogHeightFalloff;
			uniform half _FogLayersMode;
			uniform half _NoiseScale;
			uniform half3 _NoiseSpeed;
			uniform half _NoiseDistanceEnd;
			uniform half _NoiseIntensity;
			uniform half _SkyboxFogHeight;
			uniform half _SkyboxFogFalloff;
			uniform half _SkyboxFogFill;
			uniform half _SkyboxFogIntensity;
			uniform half _FogIntensity;
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
				float3 normalizeResult318_g973 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
				float dotResult145_g973 = dot( normalizeResult318_g973 , _DirectionalDir );
				float vertexToFrag438_g973 = pow( abs( ( (dotResult145_g973*0.5 + 0.5) * _DirectionalIntensity ) ) , _DirectionalFalloff );
				o.ase_texcoord2.x = vertexToFrag438_g973;
				
				
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
				float2 UV235_g973 = ase_screenPosNorm.xy;
				float2 localUnStereo235_g973 = UnStereo( UV235_g973 );
				float2 break248_g973 = localUnStereo235_g973;
				float clampDepth227_g973 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch250_g973 = ( 1.0 - clampDepth227_g973 );
				#else
				float staticSwitch250_g973 = clampDepth227_g973;
				#endif
				float3 appendResult244_g973 = (float3(break248_g973.x , break248_g973.y , staticSwitch250_g973));
				float4 appendResult220_g973 = (float4((appendResult244_g973*2.0 + -1.0) , 1.0));
				float4 break229_g973 = mul( unity_CameraInvProjection, appendResult220_g973 );
				float3 appendResult237_g973 = (float3(break229_g973.x , break229_g973.y , break229_g973.z));
				float4 appendResult233_g973 = (float4(( ( appendResult237_g973 / break229_g973.w ) * half3(1,1,-1) ) , 1.0));
				float4 break245_g973 = mul( unity_CameraToWorld, appendResult233_g973 );
				float3 appendResult239_g973 = (float3(break245_g973.x , break245_g973.y , break245_g973.z));
				float3 WorldPositionFromDepth253_g973 = appendResult239_g973;
				float3 WorldPosition2_g973 = WorldPositionFromDepth253_g973;
				float temp_output_7_0_g978 = _FogDistanceStart;
				half FogDistanceMask12_g973 = pow( abs( saturate( ( ( distance( WorldPosition2_g973 , _WorldSpaceCameraPos ) - temp_output_7_0_g978 ) / ( _FogDistanceEnd - temp_output_7_0_g978 ) ) ) ) , _FogDistanceFalloff );
				float3 lerpResult258_g973 = lerp( (_FogColorStart).rgb , (_FogColorEnd).rgb , ( saturate( ( FogDistanceMask12_g973 - 0.5 ) ) * _FogColorDuo ));
				float vertexToFrag438_g973 = i.ase_texcoord2.x;
				float DirectionalMask30_g973 = vertexToFrag438_g973;
				float3 lerpResult40_g973 = lerp( lerpResult258_g973 , (_DirectionalColor).rgb , DirectionalMask30_g973);
				#ifdef AHF_DISABLE_DIRECTIONAL
				float3 staticSwitch442_g973 = lerpResult258_g973;
				#else
				float3 staticSwitch442_g973 = lerpResult40_g973;
				#endif
				float3 temp_output_2_0_g979 = staticSwitch442_g973;
				float3 gammaToLinear3_g979 = GammaToLinearSpace( temp_output_2_0_g979 );
				#ifdef UNITY_COLORSPACE_GAMMA
				float3 staticSwitch1_g979 = temp_output_2_0_g979;
				#else
				float3 staticSwitch1_g979 = gammaToLinear3_g979;
				#endif
				float3 temp_output_256_0_g973 = staticSwitch1_g979;
				half3 AHF_FogAxisOption181_g973 = _FogAxisOption;
				float3 break159_g973 = ( WorldPosition2_g973 * AHF_FogAxisOption181_g973 );
				float temp_output_7_0_g976 = _FogHeightEnd;
				half FogHeightMask16_g973 = pow( abs( saturate( ( ( ( break159_g973.x + break159_g973.y + break159_g973.z ) - temp_output_7_0_g976 ) / ( _FogHeightStart - temp_output_7_0_g976 ) ) ) ) , _FogHeightFalloff );
				float lerpResult328_g973 = lerp( ( FogDistanceMask12_g973 * FogHeightMask16_g973 ) , saturate( ( FogDistanceMask12_g973 + FogHeightMask16_g973 ) ) , _FogLayersMode);
				float mulTime204_g973 = _Time.y * 2.0;
				float3 temp_output_197_0_g973 = ( ( WorldPosition2_g973 * ( 1.0 / _NoiseScale ) ) + ( -_NoiseSpeed * mulTime204_g973 ) );
				float3 p1_g975 = temp_output_197_0_g973;
				float localSimpleNoise3D1_g975 = SimpleNoise3D( p1_g975 );
				float temp_output_7_0_g974 = _NoiseDistanceEnd;
				half NoiseDistanceMask7_g973 = saturate( ( ( distance( WorldPosition2_g973 , _WorldSpaceCameraPos ) - temp_output_7_0_g974 ) / ( 0.0 - temp_output_7_0_g974 ) ) );
				float lerpResult198_g973 = lerp( 1.0 , (localSimpleNoise3D1_g975*0.5 + 0.5) , ( NoiseDistanceMask7_g973 * _NoiseIntensity ));
				half NoiseSimplex3D24_g973 = lerpResult198_g973;
				#ifdef AHF_DISABLE_NOISE3D
				float staticSwitch42_g973 = lerpResult328_g973;
				#else
				float staticSwitch42_g973 = ( lerpResult328_g973 * NoiseSimplex3D24_g973 );
				#endif
				float3 normalizeResult169_g973 = normalize( ( WorldPosition2_g973 - _WorldSpaceCameraPos ) );
				float3 break170_g973 = ( normalizeResult169_g973 * AHF_FogAxisOption181_g973 );
				float temp_output_7_0_g977 = _SkyboxFogHeight;
				float saferPower309_g973 = max( abs( saturate( ( ( abs( ( break170_g973.x + break170_g973.y + break170_g973.z ) ) - temp_output_7_0_g977 ) / ( 0.0 - temp_output_7_0_g977 ) ) ) ) , 0.0001 );
				float lerpResult179_g973 = lerp( pow( saferPower309_g973 , _SkyboxFogFalloff ) , 1.0 , _SkyboxFogFill);
				half SkyboxFogHeightMask108_g973 = ( lerpResult179_g973 * _SkyboxFogIntensity );
				float clampDepth118_g973 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch123_g973 = clampDepth118_g973;
				#else
				float staticSwitch123_g973 = ( 1.0 - clampDepth118_g973 );
				#endif
				half SkyboxMask95_g973 = ( 1.0 - ceil( staticSwitch123_g973 ) );
				float lerpResult112_g973 = lerp( staticSwitch42_g973 , SkyboxFogHeightMask108_g973 , SkyboxMask95_g973);
				float temp_output_43_0_g973 = ( lerpResult112_g973 * _FogIntensity );
				float4 appendResult114_g973 = (float4(temp_output_256_0_g973 , temp_output_43_0_g973));
				
				
				finalColor = appendResult114_g973;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "HeightFogShaderGUI"
	
	
}
/*ASEBEGIN
Version=18800
1920;13;1906;1009;4143.203;5027.952;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;1093;-3328,-4736;Inherit;False;Property;_Banner;Banner;0;0;Create;True;0;0;0;True;1;StyledBanner(Height Fog Standalone);False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1107;-3136,-4736;Half;False;Property;_HeightFogStandalone;_HeightFogStandalone;32;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1106;-2880,-4736;Half;False;Property;_IsHeightFogShader;_IsHeightFogShader;33;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1119;-3328,-4608;Inherit;False;Base;1;;973;13c50910e5b86de4097e1181ba121e0e;26,355,1,361,1,347,1,382,1,370,1,372,1,368,1,392,1,343,1,366,1,345,1,364,1,360,1,354,1,116,1,351,1,378,1,380,1,388,1,339,1,384,1,99,1,386,1,349,1,376,1,374,1;0;4;FLOAT4;113;FLOAT3;86;FLOAT;87;FLOAT;445
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;383;-3072,-4608;Float;False;True;-1;2;HeightFogShaderGUI;0;1;BOXOPHOBIC/Atmospherics/Height Fog Standalone;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;1;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;222;False;-1;255;False;-1;255;False;-1;6;False;-1;2;False;-1;0;False;-1;0;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;594;True;7;False;595;True;False;0;False;500;1000;False;500;True;2;RenderType=Overlay=RenderType;Queue=Overlay=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;LightMode=ForwardBase;PreviewType=Skybox;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;1105;-3328,-4864;Inherit;False;919.8825;100;Drawers;0;;1,0.475862,0,1;0;0
WireConnection;383;0;1119;113
ASEEND*/
//CHKSM=5F3F7311F0A8279733807D7B522767FC429048AE