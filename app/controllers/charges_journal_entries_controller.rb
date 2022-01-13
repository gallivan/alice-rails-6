class ChargesJournalEntriesController < InheritedResources::Base

  private

    def charges_journal_entry_params
      params.require(:charges_journal_entry).permit(:charge_id, :journal_entry_id)
    end
end

