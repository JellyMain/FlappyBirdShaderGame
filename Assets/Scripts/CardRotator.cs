using System;
using UnityEngine;


public class CardRotator : MonoBehaviour
{
    [SerializeField] InputService inputService;
    [SerializeField, Range(0, 1)] private float sensitivity = 0.4f;
    [SerializeField] private float rotationSpeed = 5;
    private Vector3 targetCardRotation = Vector3.zero;
    private Quaternion lastRotation;
    private bool canRotate;



    private void OnEnable()
    {
        inputService.OnMouseDown += OnMouseDown;
        inputService.OnMouseUp += OnMouseUp;
    }


    private void OnDisable()
    {
        inputService.OnMouseDown -= OnMouseDown;
        inputService.OnMouseUp -= OnMouseUp;
    }


    private void Start()
    {
        lastRotation = transform.rotation;
    }
    


    private void OnMouseDown()
    {
        canRotate = true;
    }


    private void OnMouseUp()
    {
        canRotate = false;
    }


    private void Update()
    {
        if (canRotate)
        {
            Vector2 mouseDelta = inputService.GetMouseDelta() * sensitivity;

            targetCardRotation.x -= mouseDelta.y;
            targetCardRotation.z -= mouseDelta.x;

            
            transform.rotation = Quaternion.Lerp(lastRotation,
                Quaternion.Euler(targetCardRotation), Time.deltaTime * rotationSpeed);

            lastRotation = transform.rotation;
        }
        else
        {
            transform.rotation = lastRotation;
            targetCardRotation = lastRotation.eulerAngles;
        }
    }
}
