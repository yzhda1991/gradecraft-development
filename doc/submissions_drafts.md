# Submission Drafts

Student submission content, namely `text_comment`, is autosaved on change at a debounce interval of 3.5sec. Content is saved onto the `Submission` on the `text_comment_draft` field.

A submission draft is an implied state, where it is defined as having `submitted_at = nil`

This definition is on the `Submission` model and named `draft?`. Under usual circumstances, the `SubmissionProctor` can be used to filter out `viewable?` submissions.

Once a user submits a submission, the `text_comment_draft` is cleared out by `Services::DeletesSubmissionDraftContent`
