using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    public static Player Instance = null;

    public Camera mCamera;

    public CharacterController mCharCtrl;

    public Light mLight;

    private Animation mAnim;

    private List<Material> mMatList = new List<Material>();

    #region 内置函数

    private void Awake()
    {
        Instance = this;

        SkinnedMeshRenderer[] renderlist = GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach(var render in renderlist)
        {
            if (render == null)
                continue;

            mMatList.Add(render.material);
        }
    }

    // Use this for initialization
    void Start () 
    {
        mAnim = GetComponentInChildren<Animation>();
    }

    // Update is called once per frame
    void Update ()
    {
        UpdatePos();
        UpdateShader();
    }

    #endregion

    #region 函数

    private void UpdatePos()
    {
        float deltax = Input.GetAxis("Horizontal");
        float deltay = Input.GetAxis("Vertical");
        if (Mathf.Abs(deltax) <= 0.01f && Mathf.Abs(deltay) <= 0.01f)
        {
            mAnim.Play("idle1");
            return;
        }

        Vector3 realdir = new Vector3(deltax, 0.0f, deltay);
        realdir = Quaternion.AngleAxis(mCamera.transform.eulerAngles.y, Vector3.up) * realdir;

        float angle = Vector3.Angle(transform.forward, realdir);
        realdir = Vector3.Slerp(transform.forward, realdir, Mathf.Clamp01(180 * Time.deltaTime * 5 / angle));
        transform.LookAt(transform.position + realdir);

        mCharCtrl.SimpleMove(realdir * 5);
        mAnim.Play("walk");
    }

    private void UpdateShader()
    {
        Vector4 worldpos = transform.position;

        //Vector4 projdir = new Vector4(-0.06323785f, -0.9545552f, -0.2912483f, 1.0f);
        //mLight.transform.rotation = Quaternion.LookRotation(projdir);

        Vector4 projdir = mLight.transform.forward;

        foreach (var mat in mMatList)
        {
            if (mat == null)
                continue;

            mat.SetVector("_WorldPos", worldpos);
            mat.SetVector("_ShadowProjDir", projdir);
            mat.SetVector("_ShadowPlane", new Vector4(0.0f, 1.0f, 0.0f, 0.1f));
            mat.SetVector("_ShadowFadeParams", new Vector4(0.0f, 1.5f, 0.7f, 0.0f));
        }
    }

    #endregion
}
