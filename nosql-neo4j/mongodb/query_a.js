db.students.find(
  {
      "id": 12147897,
      
  }, {
          "enrolled_in.program.designation": 1,
  })
  