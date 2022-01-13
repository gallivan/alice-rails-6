class AlterFeesByExchangeAndPostedOnProxy < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
              DROP VIEW IF EXISTS fees_by_exchange_and_posted_on_view;
              CREATE VIEW
                 fees_by_exchange_and_posted_on_view AS
              SELECT
                  f.posted_on,
                  t.id                    AS fee_chargeable_type_id,
                  x.id                    AS currency_id,
                  e.id                    AS entity_id,
                  SUM(ROUND(f.amount, 2)) AS amount
              FROM
                  fees f,
                  entities e,
                  currencies x,
                  claim_sets s,
                  fee_chargeables c,
                  fee_chargeable_types t
              WHERE
                  s.id = c.claim_set_id AND
                  x.id = c.currency_id AND
                  c.id = f.fee_chargeable_id AND
                  t.id = c.fee_chargeable_type_id AND
                  e.code = split_part(s.code, ':', 1)
              GROUP BY
                  f.posted_on,
                  t.id,
                  x.id,
                  e.id
              ORDER BY
                  posted_on DESC,
                  e.code,
                  t.code,
                  x.code
             )
    execute(sql)

    unless EntityType.find_by_code('CRP').blank?
      Entity.create! do |e|
        e.code = 'IFEU'
        e.name = 'ICE Futures Europe'
        e.entity_type_id = EntityType.find_by_code('CRP').id
      end

      Entity.create! do |e|
        e.code = 'LIFFE'
        e.name = 'London International Financial Futures Exchange'
        e.entity_type_id = EntityType.find_by_code('CRP').id

      end

      Entity.create! do |e|
        e.code = 'MNP'
        e.name = 'MONEP'
        e.entity_type_id = EntityType.find_by_code('CRP').id
      end
    end

  end

  def down
    Entity.find_by_code('MNP').destroy
    Entity.find_by_code('LIFFE').destroy
    Entity.find_by_code('IFEU').destroy
    execute('drop view if exists fees_by_exchange_and_posted_on_view')
  end
end
