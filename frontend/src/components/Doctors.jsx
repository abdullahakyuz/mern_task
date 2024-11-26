import { useState } from "react";
import Col from "react-bootstrap/Col";
import Container from "react-bootstrap/Container";
import Image from "react-bootstrap/Image";
import Row from "react-bootstrap/Row";
import { doctorData } from "../helpers/data";
import AddModal from "./AddModal";
import { addLocal } from "../helpers/utils";

const Doctors = ({ apps, setApps }) => {

  const [showModal, setShow] = useState(false);
  const [drName, setDrName] = useState("");

  console.log("Appointments güncellendi Home Componenti render olduğu için Doctors Componenti render oldu.")

  const addAppointment = (newAppo) => {
    setApps([...apps, newAppo]);

    addLocal("appointments",[...apps, newAppo])
  };
  return (
    <Container>
      <h3 className="display-6 mb-3" style={{ color: "rgb(166, 18, 189)" }}>
        Our Doctors
      </h3>
      <Row>

        {doctorData.map(({ id, img, name, dep }) => (
          <Col xs={6} sm={4} lg={3} key={id}>
            <Image
              className="img-thumbnail doctor-img w-100"
              src={img}
              alt={name}
              onClick={() => {
                setShow(true);
                setDrName(name); 
              }}
            />
            <h5>{name}</h5>
            <p>{dep}</p>
          </Col>
        ))}
      </Row>
      <AddModal
        showModal={showModal}
        handleClose={() => setShow(false)}
        drName={drName}
        addAppointment={addAppointment}
      />
    </Container>
  );
};

export default Doctors;
