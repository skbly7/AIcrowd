function resetChallengesFormClientValidations() {
  // We need to wait till fields show up in browser
  setTimeout(function() { $('#challenges-form').enableClientSideValidations(); }, 1000);
}

Paloma.controller('Challenges', {
    reorder: function () {
        let calculateIndex = function () {
            let landingPageIdx = 6;
            let l = $(".challenge-list-row .new-seq");
            for (let i = 0; i < l.length; i++) {
                l[i].innerText = i.toString();
                let current = $(l[i].parentNode);
                // Hidden and Private challenges have a badge!
                let hasBadge = current.has('.badge').length > 0;
                let draftChallenge = current.children()[1].textContent === "draft";
                if (i < landingPageIdx) {
                    if (hasBadge || draftChallenge) {
                        landingPageIdx++;
                        continue;
                    }
                    $(current).addClass('table-success');
                } else {
                    $(current).removeClass('table-success');
                }
            }
        };
        $(function () {
            let selected_sortable = $("#sortable");
            calculateIndex();
            selected_sortable.sortable({
                update: function (event, ui) {
                    calculateIndex();
                    let order = $("#sortable").sortable("toArray");
                    order[0] && $('#order').val(order.join(","));
                }
            });
            selected_sortable.disableSelection();
            let order = selected_sortable.sortable("toArray");
            order[0] && $('#order').val(order.join(","));
        });
    },
    edit: function () {
        const currentUrl  = new URL(window.location);
        const currentStep = currentUrl.searchParams.get('step');
        const currentTab  = $(`#challenge-edit-${currentStep}-tab`);

        let switch_handler = function () {
          $('.active-switch').each((event, checkbox) => {
              if (checkbox !== this) {
                  checkbox.checked = false;
              }
          });
        };

        $("#rounds").on('cocoon:after-insert', function(event, added_round) {
          added_round.find('.active-switch').on('click', switch_handler);
        });

        $('.challenges-form-tab-link').click(function(event) {
          const tabLink = $(event.target).tab('show');

          event.preventDefault();

          // Set step in URL address
          currentUrl.searchParams.set('step', event.target.dataset.currentTab);
          window.history.pushState(null, null, currentUrl.toString());

          resetChallengesFormClientValidations();
        });

        $('.active-switch').on('click', switch_handler);

        $('.challenges-form__toggle-expand').click(function(event) {
          resetChallengesFormClientValidations();
        });

        $('#replace-rules-button').click(function (event) {
          $(this).hide()
          resetChallengesFormClientValidations();
        });

        $('#challenges-form-add-partner').click(function() {
          resetChallengesFormClientValidations();
        });

        $('#challenges-form-add-round').click(function() {
          resetChallengesFormClientValidations();

          setTimeout(function() {
            $('.challenges-form__toggle-expand').click(function(event) {
              resetChallengesFormClientValidations();
            });
          }, 1000);
        });

        if (currentTab) {
          currentTab.tab('show');
          resetChallengesFormClientValidations();
        }
    },
    show: function () {
        let update_table_of_contents = function (heading_ids) {
            let li;
            let a;
            let toc = $("#table-of-contents");
            let done = 0;
            heading_ids.forEach(id => {
                li = document.createElement("li");
                a = document.createElement("a");
                li.classList.add('nav-item');
                a.classList.add('nav-link');
                $(a).attr('href', '#' + id.replace(/[^a-z0-9_-]/gi, ''));
                $(a).text(_.capitalize(id).replace(/-/g, ' '));
                $(li).append(a);
                toc.append(li);
                // Attach ScrollSpy only after the TOC has been generated.
                done += 1;
                if (done === heading_ids.length) {
                    $('body').scrollspy({target: "#table-of-contents", offset: 64});
                }
            });
        };
        let escapeIds = function () {
            let x = this.id;
            // Remove special chars from the ID, to make sure scrollspy does not break.
            this.id = x.replace(/[^a-z0-9_-]/gi, '');
            // But return the original for displaying
            return x;
        };
        // NATE: Apparently challenges#show is not using turbolinks
        $(document).ready(function () {
            let heading_ids = $("#description-wrapper h1").map(escapeIds).get().filter(e => e);
            update_table_of_contents(heading_ids);
        });
    }
});
