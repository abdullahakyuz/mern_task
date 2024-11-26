import { useState } from "react";
import Button from "react-bootstrap/Button";
import Form from "react-bootstrap/Form";
import Modal from "react-bootstrap/Modal";

function AddModal({ showModal, handleClose, drName, addAppointment }) {
  console.log("Appointments güncellendi Home Componenti render olduğu için Doctors Componenti render olduğu için AddModal render oldu.")
  const [patientName, setPatientName] = useState("");
  const [date, setDate] = useState("");
  const handleSubmit = (e) => {
    e.preventDefault();
    console.log({ patientName, date, drName });

    addAppointment({
      id: crypto.randomUUID(),
      patient: patientName,
      day: date,
      consulted: false,
      doctor: drName,
    });
    setPatientName("")
    setDate("")
    handleClose()
  };
  
  
  return (
    <>
      <Modal show={showModal} onHide={handleClose} size={"lg"}>
        <Modal.Header closeButton>
          <Modal.Title>Appointment for : {drName} </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Form onSubmit={handleSubmit}>
            <Form.Group className="mb-3" controlId="formBasicText">
              <Form.Label>Patient Name</Form.Label>
              <Form.Control
                type="text"
                placeholder="Enter patient name"
                onChange={(e) => setPatientName(e.target.value)}
                value={patientName} 
              />
            </Form.Group>

            <Form.Group className="mb-3" controlId="formBasicDate">
              <Form.Label>Date</Form.Label>
              <Form.Control
                type="datetime-local"
                placeholder="Date"
                onChange={(e) => setDate(e.target.value)}
                value={date}
              />
            </Form.Group>
            <div className="text-center">
              <Button variant="success" type="submit" className="me-2">
                Save
              </Button>
              <Button variant="danger" onClick={handleClose}>
                Close
              </Button>
            </div>
          </Form>
        </Modal.Body>
      </Modal>
    </>
  );
}

export default AddModal;
