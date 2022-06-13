db.getCollection("students").aggregate([
  {
      "$project": {
          "enrolled_in": {
              "$filter": {
                  input: "$enrolled_in",
                  as: "enrollment",
                  cond: { $ifNull: ["$$enrollment.conclusion_year", false] }
              }
          },
          "candidate_to": 1
      }
  },
  { $unwind: "$enrolled_in" },
  {
      "$project": {
          "candidate_to": {
              "$filter": {
                  input: "$candidate_to",
                  as: "candidature",
                  cond: { $eq: ["$$candidature.program.code", "$enrolled_in.program.code"] }
              }
          },
          "enrolled_in": 1,
      }
  },
  {
      $addFields: {
          enrollment_years: { $subtract: ["$enrolled_in.conclusion_year", "$enrolled_in.enroll_year"] }
      }
  },
  {
      $group: {
          "_id": { "enrollment_years": "$enrollment_years" },
          "avg_final_grade": { $avg: "$enrolled_in.final_average" }
      }
  },

  { $sort: { "_id.enrollment_years": 1 } }

])