angular.module('loomioApp').directive 'attachmentForm', ->
  scope: {comment: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment_form/attachment_form.html'
  replace: true
  controller: 'AttachmentFormController'
  link: (scope, element, attrs) ->
    element.find('#comment-form-attachment-button').on 'click', ->
      element.find('input[type="file"]').click()
