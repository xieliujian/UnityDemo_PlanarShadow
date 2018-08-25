// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "PlanarShadow/Player"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ShadowInvLen ("ShadowInvLen", float) = 1.0 //0.4449261
	}
	
	SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry+10" }
		LOD 100
		
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			
			ENDCG
		}

		Pass
		{		
			Blend SrcAlpha  OneMinusSrcAlpha
			ZWrite Off
			Cull Back
			ColorMask RGB
			
			Stencil
			{
				Ref 0			
				Comp Equal			
				WriteMask 255		
				ReadMask 255
				//Pass IncrSat
				Pass Invert
				Fail Keep
				ZFail Keep
			}
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			float4 _ShadowPlane;
			float4 _ShadowProjDir;
			float4 _WorldPos;
			float _ShadowInvLen;
			float4 _ShadowFadeParams;
			
			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 xlv_TEXCOORD0 : TEXCOORD0;
				float3 xlv_TEXCOORD1 : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;

				float3 tmpvar_1 = normalize(_ShadowProjDir);
				float3 tmpvar_2 = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 tmpvar_3 = (tmpvar_2 - (((dot(_ShadowPlane.xyz, tmpvar_2) - _ShadowPlane.w) / dot(_ShadowPlane.xyz, tmpvar_1.xyz)) * tmpvar_1.xyz));
				o.vertex = mul(unity_MatrixVP, float4(tmpvar_3, 1.0));
				o.xlv_TEXCOORD0 = _WorldPos.xyz;
				o.xlv_TEXCOORD1 = tmpvar_3;

				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float3 posToPlane_2 = (i.xlv_TEXCOORD0 - i.xlv_TEXCOORD1);
				float4 color;
				color.xyz = float3(0.0, 0.0, 0.0);
				color.w = (pow((1.0 - clamp(((sqrt(dot(posToPlane_2, posToPlane_2)) * _ShadowInvLen) - _ShadowFadeParams.x), 0.0, 1.0)), _ShadowFadeParams.y) * _ShadowFadeParams.z);

				return color;
			}
			
			ENDCG
		}
	}
}
