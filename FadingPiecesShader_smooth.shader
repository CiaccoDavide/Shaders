Shader "Custom/FadingInPieces"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_DissolveSpeed("Dissolve Speed", float) = 1.0
		_DissolveColor1("Dissolve Color 1", Color) = (1, 1, 1, 1)
		_DissolveColor2("Dissolve Color 2", Color) = (1, 1, 1, 1)
		_ColorThreshold1("Color Threshold 1", float) = 1.0
		_ColorThreshold2("Color Threshold 2", float) = 1.0
		_StartTime("Start Time", float) = 1.0
		_FadeSpeed("Fade Speed", float) = 1.0
	}

	SubShader
	{
        Tags
		{ 
			"Queue" = "Transparent"
		}

		// Regular color
		Pass
		{
            Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			// Properties
			sampler2D _MainTex;
			float4 _Color;
			float4 _DissolveColor1;
			float4 _DissolveColor2;
			sampler2D _NoiseTex;
			float _DissolveSpeed;
			float _ColorThreshold1;
			float _ColorThreshold2;
			float _StartTime;
			float _FadeSpeed;
			//float _spawnMoment;
			float _internalTime;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 texCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 texCoord : TEXCOORD0;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert input to world space
				output.pos = UnityObjectToClipPos((1+6*_internalTime)*input.vertex);

				//only for lighted objects
			//	float4 normal4 = float4(input.normal, 0.0); // need float4 to mult with 4x4 matrix
				//output.normal = normalize(mul(normal4, unity_WorldToObject).xyz);

				// texture coordinates 
				output.texCoord = input.texCoord;

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// sample texture for color
				float4 albedo = tex2D(_MainTex, input.texCoord.xy);

				// base color
				float4 col = float4(albedo.rgba * _Color.rgba);

				// sample noise texture
				float noiseSample = tex2Dlod(_NoiseTex, float4(input.texCoord.xy, 0, 0));
				
				
				
				// dissolve colors
                float thresh2 = _internalTime * _ColorThreshold2 - _StartTime;
				float useDissolve2 = noiseSample - thresh2 < 0;
				col = (1-useDissolve2)*col + useDissolve2*_DissolveColor2;

                float thresh1 = _internalTime * _ColorThreshold1 - _StartTime;
				float useDissolve1 = noiseSample - thresh1 < 0;
				col = (1-useDissolve1)*col + useDissolve1*_DissolveColor1;

				float threshold = (_internalTime ) * _DissolveSpeed- _StartTime;
				clip(noiseSample - threshold);
				


				//col.a -= saturate((_internalTime - _StartTime)* _FadeSpeed);
				col.a *= 1-noiseSample.r * 10*_internalTime ;
				col.a *= albedo.a;

				return col;
			}

			ENDCG
		}
	}
}
