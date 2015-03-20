angular.module('loomioApp').factory 'ProposalFormService', ($modal, Records) ->
  new class ProposalFormService
    openEditProposalModal: (proposal) ->
      $modal.open
        templateUrl: 'generated/components/thread_page/proposals_card/proposal_form/proposal_form.html',
        controller: 'ProposalFormController',
        resolve:
          proposal: -> Records.proposals.find(proposal.id)

    openStartProposalModal: (discussion) ->
      modalInstance = $modal.open
        templateUrl: 'generated/components/thread_page/proposals_card/proposal_form/proposal_form.html'
        controller: 'ProposalFormController'
        resolve:
          proposal: ->
            Records.proposals.initialize(discussion_id: discussion.id)

    openCloseProposalModal: (proposal) ->
      $modal.open
        templateUrl: 'generated/components/thread_page/proposals_card/close_proposal_form/close_proposal_form.html',
        controller: 'CloseProposalFormController',
        resolve:
          proposal: -> Records.proposals.find(proposal.id)

    openExtendProposalModal: (proposal) ->
      $modal.open
        templateUrl: 'generated/components/thread_page/proposals_card/extend_proposal_form/extend_proposal_form.html',
        controller: 'ExtendProposalFormController',
        resolve:
          proposal: -> Records.proposals.find(proposal.id)

