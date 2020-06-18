Shader "Dima/_Outline"
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

        _OutlineWidth("OutlineWidth",Range(0,0.05)) = 0.03
        _OutlineColor("OutlineColor",Color) = (1,1,1,1)
        [HideInInspector] _texcoord( "", 2D ) = "white" {}
    }
    SubShader
    {
        Cull Front
        CGPROGRAM
        #pragma surface surf Standard vertex:vertexFunction

        struct Input
        {
            fixed filter;
        };

        uniform fixed4 _OutlineColor;
        uniform fixed _OutlineWidth;

        void vertexFunction(inout appdata_full v){
            v.vertex.xyz += (v.normal * _OutlineWidth);
        }

        void surf(Input i,inout SurfaceOutputStandard o){
            o.Emission = _OutlineColor.rgb;
        }

        ENDCG

        Tags { "Queue" = "Overlay" }
        Cull Back
        CGPROGRAM
        #pragma surface surf Standard addshadow
        #pragma target 3.0

        #define Trform2D(name,tex) (tex2D(name,tex.xy * name##_ST.xy + name##_ST.zw))
        #define Remap(s,a1,a2,b1,b2) (b1 + (s - a1) * (b2 - b1)/(a2 - a1))

        struct Input
        {
            float2 uv_texcoord;
        };

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
