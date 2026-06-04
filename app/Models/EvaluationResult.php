<?php
/**
 * CEAMS - Evaluation Result Model
 */

namespace App\Models;

use PDO;

class EvaluationResult extends BaseModel
{
    protected $table = 'evaluation_results';
    protected $fillable = [
        'evaluation_period_id',
        'employee_id',
        'department_id',
        'supervisor_score',
        'peer_average_score',
        'final_score',
        'grade',
        'status'
    ];

    /**
     * Calculate final score
     * Formula: (Supervisor Score × 0.40) + (Peer Average × 0.60)
     */
    public function calculateFinalScore($supervisorScore, $peerAverageScore)
    {
        return ($supervisorScore * 0.40) + ($peerAverageScore * 0.60);
    }

    /**
     * Get grade from score
     */
    public function getGrade($score)
    {
        if ($score >= 9.0 && $score <= 10.0) {
            return 'A';
        } elseif ($score >= 8.0 && $score < 9.0) {
            return 'B';
        } elseif ($score >= 7.0 && $score < 8.0) {
            return 'C';
        } elseif ($score >= 6.0 && $score < 7.0) {
            return 'D';
        } else {
            return 'E';
        }
    }

    /**
     * Get evaluation period results
     */
    public function getPeriodResults($evaluationPeriodId)
    {
        $sql = "SELECT er.*, u.first_name, u.last_name, u.email, d.name as department_name
                FROM {$this->table} er
                JOIN users u ON u.id = er.employee_id
                JOIN departments d ON d.id = er.department_id
                WHERE er.evaluation_period_id = :period_id
                ORDER BY er.final_score DESC";
        $this->db->query($sql);
        $this->db->bind(':period_id', $evaluationPeriodId);
        return $this->db->resultSet();
    }

    /**
     * Get employee evaluation results
     */
    public function getEmployeeResults($employeeId, $limit = 5)
    {
        $sql = "SELECT er.*, ep.name as period_name, ep.start_date, ep.end_date
                FROM {$this->table} er
                JOIN evaluation_periods ep ON ep.id = er.evaluation_period_id
                WHERE er.employee_id = :employee_id
                ORDER BY ep.start_date DESC
                LIMIT :limit";
        $this->db->query($sql);
        $this->db->bind(':employee_id', $employeeId);
        $this->db->bind(':limit', $limit, PDO::PARAM_INT);
        return $this->db->resultSet();
    }
}
