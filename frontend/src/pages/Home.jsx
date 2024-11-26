import { useState } from "react"
import AppointmentList from "../components/AppointmentList"
import Doctors from "../components/Doctors"

const Home = () => {
  const [appointments,setAppointments] = useState(JSON.parse(localStorage.getItem("appointments")) || [])

  console.log("Appointments güncellendi Home Componenti render oldu.")
  return (
    <main className="text-center mt-2">
      <h1 className="display-5 text-danger">HOSPITAL</h1>
      <Doctors setApps={setAppointments} apps={appointments} />
      <AppointmentList apps={appointments} setApps={setAppointments} />
    </main>
  )
}

export default Home