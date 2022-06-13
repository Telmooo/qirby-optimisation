from pymongo.database import Database
import pymongo
import pandas as pd
import json

def get_database() -> Database:

  f = open('CREDENTIALS.json', 'r')
  credentials = json.load(f)
  f.close()

  client = pymongo.MongoClient(credentials['host'],
                      username=credentials['username'],
                      password=credentials['password'],
                      authSource=credentials['authSource'],
                      authMechanism=credentials['authMechanism'])

  return client.get_database(name='tbdc')


class Dataloader:

  def __init__(self, db: pymongo.MongoClient) -> None:
    self.db = db

    self.programs = pd.read_csv('../data/csv/programs.csv')
    self.candidates = pd.read_csv('../data/csv/candidates.csv')
    self.students = pd.read_csv('../data/csv/students.csv')


  def _build_program_collections(self):
    programs = []

    for row in self.programs.itertuples():
      p = {
        "code": row.CODE,
        "acronym": row.ACRONYM,
        "designation": row.DESIGNATION,
        "candidates": [],
        "students": []
      }

      candidate_subset = self.candidates[self.candidates['PROGRAM'] == row.CODE]
      for c_row in candidate_subset.itertuples():
        c = {
          "id": c_row.ID,
          "year": c_row.YEAR,
          "result": c_row.RESULT,
        }

        if not pd.isna(c_row.AVERAGE):
          c['average'] = c_row.AVERAGE

        p['candidates'].append(c)
      candidate_subset = None

      student_subset = self.students[self.students['PROGRAM'] == row.CODE]
      for s_row in student_subset.itertuples():
        s = {
          "id": s_row.ID,
          "nr": s_row.NR,
          "enroll_year": s_row.ENROLL_YEAR,
          "status": s_row.STATUS,
        }

        if not pd.isna(s_row.FINAL_AVERAGE):
          s['final_average'] = s_row.FINAL_AVERAGE
        if not pd.isna(s_row.CONCLUSION_YEAR):
          s['conclusion_year'] = s_row.CONCLUSION_YEAR

        p['students'].append(s)

      programs.append(p)

    return programs


  def create_programs_collection(self):
    programs = self._build_program_collections()
    self.db.programs.drop()
    self.db.programs.create_index([('code', pymongo.ASCENDING)], unique=True)

    self.db.programs.insert_many(programs)
    return self


  def _find_program(self, program_code):
    return self.programs[self.programs['CODE'] == program_code].iloc[0]


  def _build_student_collections(self):
    students = []
    unique_ids = self.candidates.ID.unique()

    for id in unique_ids:
      student = {
        'id': int(id),
        'candidate_to': [],
        'enrolled_in': []
      }

      cand = self.candidates[self.candidates['ID'] == id]
      for c_row in cand.itertuples():
        p = self._find_program(c_row.PROGRAM)
        candidate_to = {
          "year": c_row.YEAR,
          "result": c_row.RESULT,
          "program": {
            "code": int(p.CODE),
            "acronym": p.ACRONYM,
            "designation": p.DESIGNATION
          }
        }

        if not pd.isna(c_row.AVERAGE):
          candidate_to['average'] = c_row.AVERAGE
        
        student['candidate_to'].append(candidate_to)
      cand = None

      enroll = self.students[self.students['ID'] == id]
      for s_row in enroll.itertuples():
        p = self._find_program(s_row.PROGRAM)
        enrolled_in = {
          "nr": int(s_row.NR),
          "enroll_year": s_row.ENROLL_YEAR,
          "status": s_row.STATUS,
          "program": {
            "code": int(p.CODE),
            "acronym": p.ACRONYM,
            "designation": p.DESIGNATION
          }
        }

        if not pd.isna(s_row.CONCLUSION_YEAR):
          enrolled_in['conclusion_year'] = s_row.CONCLUSION_YEAR

        if not pd.isna(s_row.FINAL_AVERAGE):
          enrolled_in['final_average'] = s_row.FINAL_AVERAGE

        student['enrolled_in'].append(enrolled_in)
      enroll = None

      if (student['candidate_to'] == []):
        del student['candidate_to']

      if (student['enrolled_in'] == []):
        del student['enrolled_in']
      
      students.append(student)

    return students

  def create_students_collection(self):
    students = self._build_student_collections()
    self.db.students.drop()
    self.db.students.create_index([('id', pymongo.ASCENDING)], unique=True)

    self.db.students.insert_many(students)
    return self

if __name__ == "__main__":

  # Get the database
  db = get_database()

  dataloader = Dataloader(db)
  dataloader.create_programs_collection()
  dataloader.create_students_collection()

