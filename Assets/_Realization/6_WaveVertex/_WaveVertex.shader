Shader "Dima/_WaveVertex"
{
    Properties
    {
        _Color ("ColorAlbedo", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" {}
        _Occlusion ("Occlusion", 2D) = "white" {}
        _Emission ("Emission", 2D) = "white" {}
        _Normal ("NormalMap", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Tessellate ("Tessellate", Range(1,10)) = 1.0
        _PassWave ("PassWave", Range(1,50)) = 5.0
        _WaveAmount ("WaveAmount", Range(0.0,0.5)) = 1.0
        _WaveDirectionSpeed("WaveDirectionSpeed",Vector) = (0,0,0,0)

        [HideInInspector] _texcoord( "", 2D ) = "white" {}
    }
    SubShader
    {
        Tags { "Queue" = "Overlay" }
        CGPROGRAM
        #pragma surface surf Standard addshadow tessellate:tessFunction vertex:vertexFunction
        #pragma target 3.0

        #define Trform2D(name,tex) (tex2D(name,tex.xy * name##_ST.xy + name##_ST.zw))
        #define Remap(s,a1,a2,b1,b2) (b1 + (s - a1) * (b2 - b1)/(a2 - a1))


        sampler2D _MainTex;
        float4 _MainTex_ST;

        sampler2D _Occlusion;
        float4 _Occlusion_ST;

        sampler2D _Emission;
        float4 _Emission_ST;

        sampler2D _Normal;
        float4 _Normal_ST;

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        half _Tessellate;
        half _PassWave;
        fixed _WaveAmount;

        fixed4 _WaveDirectionSpeed;

        struct Input
        {
            float2 uv_texcoord;
        };

        float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
        {
            return (_Tessellate).xxxx;
        }

        void vertexFunction( inout appdata_full v )
        {
            float3 normalVertex = v.normal.xyz;
            float3 posVertex = v.vertex.xyz;
            v.vertex.xyz += max(sin(((posVertex.xyz * _WaveDirectionSpeed.xyz) * _Time.x) * _PassWave) * _WaveAmount,0.0) * normalVertex;
        }

        void surf (Input i, inout SurfaceOutputStandard o){
            o.Albedo = (Trform2D(_MainTex,i.uv_texcoord) * _Color).rgb;
            o.Occlusion = Trform2D(_Occlusion,i.uv_texcoord).rgb;
            o.Emission = Trform2D(_Emission,i.uv_texcoord).rgb;
            o.Normal = UnpackNormal(Trform2D(_Normal,i.uv_texcoord));
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
