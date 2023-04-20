using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovementAndFoot : MonoBehaviour
{
    public enum enumFoot
    {
        Left,
        Right,
    }

    [SerializeField]
    private Transform playerCamera;

    [SerializeField]
    private float mouseSensitivity = 3.5f;
    
    [SerializeField]
    private float walkSpeed = 3.0f;

    [SerializeField]
    private float gravity = -13.0f;

    [SerializeField]
    [Range(0.0f, 0.5f)] private float moveSmoothTime = 0.2f;

    [SerializeField]
    [Range(0.0f, 0.5f)] private float mouseSmoothTime = 0.03f;

    private float cameraPitch = 0.0f;
    private float velocityY = 0.0f;
    private CharacterController controller = null;

    private Vector2 currentDir = Vector2.zero;
    private Vector2 currentDirVelocity = Vector2.zero;

    private Vector2 currentMouseDelta = Vector2.zero;
    private Vector2 currentMouseDeltaVelocity = Vector2.zero;

    public GameObject LeftPrefab = null;
    public GameObject RightPrefab = null;
    public float FootprintSpacer = 1.0f;
    private Vector3 LastFootprint;
    private enumFoot WhichFoot;
    private bool TouchingGround;

    private void Start()
    {
        controller = GetComponent<CharacterController>();

        //SpawnDecal(LeftPrefab);
        LastFootprint = this.transform.position;

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    private void Update()
    {
        MouseLook();
        Movement();
    }

    private void MouseLook()
    {
        Vector2 targetMouseDelta = new Vector2(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"));

        currentMouseDelta = Vector2.SmoothDamp(currentMouseDelta, targetMouseDelta, ref currentMouseDeltaVelocity, mouseSmoothTime);

        cameraPitch -= currentMouseDelta.y * mouseSensitivity;
        cameraPitch = Mathf.Clamp(cameraPitch, -90.0f, 90.0f);

        playerCamera.localEulerAngles = Vector3.right * cameraPitch;
        transform.Rotate(Vector3.up * currentMouseDelta.x * mouseSensitivity);
    }

    private void Movement()
    {
        Vector2 targetDir = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
        targetDir.Normalize();

        currentDir = Vector2.SmoothDamp(currentDir, targetDir, ref currentDirVelocity, moveSmoothTime);

        if(controller.isGrounded)
            velocityY = 0.0f;

        velocityY += gravity * Time.deltaTime;
		
        Vector3 velocity = (transform.forward * currentDir.y + transform.right * currentDir.x) * walkSpeed + Vector3.up * velocityY;

        controller.Move(velocity * Time.deltaTime);

        if (targetDir.x != 0 && controller.isGrounded)
        {
            // Distance since last footprint
           // float DistanceSinceLastFootPrint = Vector3.Distance(LastFoodprint, this.transform.position);

           /* if (DistanceSinceLastFootPrint >= FootprintSpacer)
            {
                //SpawnDecal(LeftPrefab);
                WhichFoot = enumFoot.Right;
            }
            else if (WhichFoot == enumFoot.Right)
            {
                //SpawnDecal(RightPrefab);
                WhichFoot = enumFoot.Left;
            }
            LastFootprint = this.transform.position;*/
        }
    }
    private void OnControllerColliderHit(ControllerColliderHit hit)
    {
        if (hit.gameObject.name == "Floor")
        {
        TouchingGround = true;
        //SpawnDecal(LeftPrefab);
        //SpawnDecal(RightPrefab);
        }
    }

}

