db.getCollection("students").aggregate([
  {
      "$project": {
          "enrolled_in": {
              "$filter": {
                  input: "$enrolled_in",
                  as: "enrollment",
                  cond: { $gt: ["$$enrollment.enroll_year", 1991] }
              }
          }
      }
  },
  { $unwind: "$enrolled_in" },

  {
      $group: {
          "_id": {
              "year": "$enrolled_in.enroll_year",
              "program": "$enrolled_in.program.code",
              "designation": "$enrolled_in.program.designation"
          },
          "n_students": { $sum: 1 }
      }
  },
  { $sort: { "_id.designation": 1, "_id.year": 1 } }
])